import 'package:flutter/material.dart';
import '../../../../core/data/model/customer_visit_model.dart';
import '../../../../core/domain/data_store/merchant_dashboard_store.dart';
import '../../../../core/services/service.dart';
import '../../../chat_feature/models/inquiry.dart';

// Enums for better type safety
enum InquiryTab { visits, inquiries }

enum InquiryStatus { pending, inProgress, resolved, closed }

enum LoadingState { idle, loading, success, error }

enum SortBy { date, status, customer }

class CustomerInquiriesProvider extends ChangeNotifier {
  final CustomerVisitService _customerVisitService;
  final ProductService _productService;
  final MerchantDashboardStore _dashboardStore;

  CustomerInquiriesProvider(
    this._customerVisitService,
    this._productService,
    this._dashboardStore,
  );

  // State variables
  InquiryTab _selectedTab = InquiryTab.visits;
  LoadingState _loadingState = LoadingState.idle;
  LoadingState _inquiryLoadingState = LoadingState.idle;
  String _errorMessage = '';
  String _searchQuery = '';
  InquiryStatus? _statusFilter;
  SortBy _sortBy = SortBy.date;

  // Data
  List<CustomerVisit> _visits = [];
  List<Inquiry> _inquiries = [];
  List<CustomerVisit> _filteredVisits = [];
  List<Inquiry> _filteredInquiries = [];

  // Pagination (not used if API doesn't support)
  bool _hasMoreVisits = false;
  bool _hasMoreInquiries = false;

  // Merchant id (set from DI or constructor)
  int get merchantId => _dashboardStore.merchantId;

  // Getters
  InquiryTab get selectedTab => _selectedTab;
  LoadingState get loadingState => _loadingState;
  LoadingState get inquiryLoadingState => _inquiryLoadingState;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  InquiryStatus? get statusFilter => _statusFilter;
  SortBy get sortBy => _sortBy;

  List<CustomerVisit> get visits => _filteredVisits;
  List<Inquiry> get inquiries => _filteredInquiries;

  bool get hasMoreVisits => _hasMoreVisits;
  bool get hasMoreInquiries => _hasMoreInquiries;
  bool get isLoadingVisits => _loadingState == LoadingState.loading;
  bool get isLoadingInquiries => _inquiryLoadingState == LoadingState.loading;

  // Statistics
  int get totalVisits => _filteredVisits.length;
  int get totalInquiries => _filteredInquiries.length;
  int get pendingInquiries =>
      _filteredInquiries.where((i) => i.status == 'pending').length;
  int get resolvedInquiries =>
      _filteredInquiries.where((i) => i.status == 'resolved').length;

  // Initialize data from server
  void init() {
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    _loadingState = LoadingState.loading;
    _inquiryLoadingState = LoadingState.loading;
    _errorMessage = '';
    notifyListeners();
    try {
      await Future.wait([loadVisitsFromApi(), loadInquiriesFromApi()]);
      _loadingState = LoadingState.success;
      _inquiryLoadingState = LoadingState.success;
    } catch (e) {
      _loadingState = LoadingState.error;
      _inquiryLoadingState = LoadingState.error;
      _errorMessage = 'Failed to load data: ${e.toString()}';
    }
    _applyFilters();
    notifyListeners();
  }

  Future<void> loadVisitsFromApi() async {
    try {
      _loadingState = LoadingState.loading;
      notifyListeners();
      final response = await _customerVisitService.getMerchantVisits(
        merchantId,
      );
      final allVisits = response.data ?? [];
      // Deduplicate by customer id, keep only latest visit per customer
      final Map<String, CustomerVisit> unique = {};
      for (final v in allVisits) {
        final cid = v.customer.id;
        if (!unique.containsKey(cid) ||
            DateTime.parse(
              v.dated,
            ).isAfter(DateTime.parse(unique[cid]!.dated))) {
          unique[cid] = v;
        }
      }
      _visits = unique.values.toList();
      _hasMoreVisits = false;
      _loadingState = LoadingState.success;
    } catch (e) {
      _loadingState = LoadingState.error;
      _errorMessage = 'Failed to load visits: ${e.toString()}';
    }
    _applyFilters();
    notifyListeners();
  }

  Future<void> loadInquiriesFromApi() async {
    try {
      _inquiryLoadingState = LoadingState.loading;
      notifyListeners();
      _inquiries = await _productService.getInquiry(merchantId.toString());
      // result is likely a List<Map<String, dynamic>>

      _hasMoreInquiries = false;
      _inquiryLoadingState = LoadingState.success;
    } catch (e) {
      _inquiryLoadingState = LoadingState.error;
      _errorMessage = 'Failed to load inquiries: ${e.toString()}';
    }
    _applyFilters();
    notifyListeners();
  }

  // Fix API fields for Inquiry.fromJson

  // Tab management
  void setSelectedTab(InquiryTab tab) {
    if (_selectedTab != tab) {
      _selectedTab = tab;
      notifyListeners();
    }
  }

  // Search functionality
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Filter functionality
  void setStatusFilter(InquiryStatus? status) {
    _statusFilter = status;
    _applyFilters();
    notifyListeners();
  }

  // Sort functionality
  void setSortBy(SortBy sortBy) {
    _sortBy = sortBy;
    _applyFilters();
    notifyListeners();
  }

  // Apply filters and sorting
  void _applyFilters() {
    // Filter visits
    _filteredVisits =
        _visits.where((visit) {
          final matchesSearch =
              _searchQuery.isEmpty ||
              visit.customer.username.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              visit.message.toLowerCase().contains(_searchQuery.toLowerCase());
          return matchesSearch;
        }).toList();

    // Filter inquiries
    _filteredInquiries =
        _inquiries.where((inquiry) {
          final matchesSearch =
              _searchQuery.isEmpty ||
              (inquiry.customerName?.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ??
                  false) ||
              inquiry.subject.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              inquiry.message.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );
          final matchesStatus =
              _statusFilter == null ||
              inquiry.status == _statusFilter.toString().split('.').last;
          return matchesSearch && matchesStatus;
        }).toList();

    // Apply sorting
    _applySorting();
  }

  void _applySorting() {
    switch (_sortBy) {
      case SortBy.date:
        _filteredVisits.sort(
          (a, b) => DateTime.parse(b.dated).compareTo(DateTime.parse(a.dated)),
        );
        _filteredInquiries.sort(
          (a, b) => _parseDate(b.createdAt).compareTo(_parseDate(a.createdAt)),
        );
        break;
      case SortBy.status:
        _filteredInquiries.sort((a, b) => a.status.compareTo(b.status));
        break;
      case SortBy.customer:
        _filteredVisits.sort(
          (a, b) => a.customer.username.compareTo(b.customer.username),
        );
        _filteredInquiries.sort(
          (a, b) => (a.customerName ?? '').compareTo(b.customerName ?? ''),
        );
        break;
    }
  }

  DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime(1970);
    if (date is DateTime) return date;
    try {
      return DateTime.parse(date.toString());
    } catch (_) {
      return DateTime(1970);
    }
  }

  // Load more data (pagination, not used if API doesn't support)
  Future<void> loadMoreVisits() async {}
  Future<void> loadMoreInquiries() async {}

  // Refresh data
  Future<void> refresh() async {
    await _fetchAll();
  }

  // Update inquiry status
  Future<void> updateInquiryStatus(int inquiryId, String status) async {
    try {
      final index = _inquiries.indexWhere((i) => i.id == inquiryId);
      if (index != -1) {
        _inquiries[index] = _inquiries[index].copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to update inquiry: ${e.toString()}';
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
