// View Model for All Categories Page
import 'package:flutter/foundation.dart';

import '../../../core/data/model/model.dart';
import '../../../core/domain/data_store/category_store.dart';
import '../../../core/domain/use_cases/api_call_use_cases.dart';
import 'package:pack/services/service.dart';

class AllCategoriesScreenProvider extends ChangeNotifier {
  final CategoryStore _categoryStore;
  final ApiCallUseCase _apiCallUseCase;

  bool _isLoading = false;
  NetworkFailure? _error;
  List<CategoryModel> _allCategories = [];
  List<CategoryModel> _filteredCategories = [];
  String _searchQuery = '';
  DateTime? _lastFetchTime;

  AllCategoriesScreenProvider(this._categoryStore, this._apiCallUseCase) {
    // Initialize with data from HomeViewModel if available
    if (_categoryStore.items.isNotEmpty) {
      _allCategories = _categoryStore.items;
      _filteredCategories = _allCategories;
      _lastFetchTime = DateTime.now();
    } else {
      fetchServices();
    }
  }

  bool get isLoading => _isLoading;
  NetworkFailure? get error => _error;
  List<CategoryModel> get categories => _filteredCategories;
  String get searchQuery => _searchQuery;

  // Fetch services from repository or use cached data
  Future<void> fetchServices() async {
    // Check if data was fetched recently to avoid redundant API calls
    if (_lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!).inMinutes < 15 &&
        _allCategories.isNotEmpty) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiCallUseCase.fetchCategories();

      result.fold(
        (failure) {
          _error = failure;
          // Log error for debugging
        },
        (services) {
          _allCategories = services;
          _applySearch(); // Apply any existing search filter
          _lastFetchTime = DateTime.now();
        },
      );
    } catch (e) {
      _error = NetworkFailure(message: e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search services based on query
  void searchServices(String query) {
    _searchQuery = query;
    _applySearch();
    notifyListeners();
  }

  // Apply search filter to all services
  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredCategories = _allCategories;
    } else {
      _filteredCategories =
          _allCategories
              .where(
                (service) =>
                    service.title.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    (service.category.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ??
                        false),
              )
              .toList();
    }
  }

  // Refresh data on demand
  Future<void> refreshData() async {
    _lastFetchTime = null; // Reset last fetch time to force a refresh
    await fetchServices();
  }

  // Clear search query
  void clearSearch() {
    if (_searchQuery.isNotEmpty) {
      _searchQuery = '';
      _filteredCategories = _allCategories;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Cleanup resources if needed
    super.dispose();
  }
}
