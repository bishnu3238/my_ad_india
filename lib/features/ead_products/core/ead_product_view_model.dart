import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:pack/services/failure/failure.dart';

import '../../../core/data/model/model.dart';
import '../../../core/domain/data_store/data_store.dart';
import '../../../core/domain/use_cases/api_call_use_cases.dart';
import 'ead_product_navigator.dart';
import 'ead_product_state.dart';

class EadProductsViewModel extends ChangeNotifier {
  final String id;
  final ProductSearchBy type;
  final ProductStore _eadProductStore;
  final CategoryStore _categoryStore;
  final SubCategoryStore _subCategoryStore;
  final ServiceStore _serviceStore;
  final AppMerchantsStore _merchantStore;
  final ApiCallUseCase _apiCallUseCase;

  ProductState _state = const ProductState();
  List<String> categories = ['All'];
  DateTime? _lastFetchTime;
  String? _title = '';
  int _selectedChipIndex = 0;
  String _selectedSortOption = 'Recommended';
  bool _isGridView = true;

  // Getters
  ProductState get state => _state;
  bool get isLoading => _state.isLoading;
  String get title => _title!;
  NetworkFailure? get error => _state.error;
  List<ProductModel> get products => _state.filteredProducts;
  String get searchQuery => _state.searchQuery;
  int get selectedChipIndex => _selectedChipIndex;
  String get selectedSortOption => _selectedSortOption;
  bool get isGridView => _isGridView;

  EadProductsViewModel(
      this._eadProductStore,
      this._apiCallUseCase,
      this._categoryStore,
      this._subCategoryStore,
      this._serviceStore,
      this._merchantStore, {
        this.id = '0',
        this.type = ProductSearchBy.all,
      }) {
    WidgetsBinding.instance.addPostFrameCallback(
          (_) async => await fetchProducts(),
    );

    _setTitle();
  }

  // Set state utility method
  void _setState(ProductState newState) {
    _state = newState;
    notifyListeners();
  }

  // Toggle search bar visibility
  void toggleSearchBarVisibility(bool isVisible) {
    _setState(_state.copyWith(isSearchBarVisible: isVisible));
  }

  // Toggle view mode (grid/list)
  void toggleViewMode(bool isGrid) {
    _isGridView = isGrid;
    notifyListeners();
  }

  // Set sorting option
  void setSortOption(String option) {
    _selectedSortOption = option;
    _applySorting();
    notifyListeners();
  }

  // Apply sorting based on selected option
  void _applySorting() {
    final List<ProductModel> sortedList = List.from(_state.filteredProducts);

    switch (_selectedSortOption) {
      case 'Newest':
      // Sort by newest first (assuming there's a dateCreated field or similar)
      // For this example, we'll use the product ID as a proxy for creation date
        sortedList.sort((a, b) => b.id.compareTo(a.id));
        break;
      case 'Price: Low to High':
        sortedList.sort((a, b) => a.planRate.compareTo(b.planRate));
        break;
      case 'Price: High to Low':
        sortedList.sort((a, b) => b.planRate.compareTo(a.planRate));
        break;
      case 'Nearby':
      // In a real implementation, this would use actual distance calculations
      // For now, we'll just keep the existing order
        break;
      case 'Recommended':
      default:
      // Default sorting (could be based on relevance, ratings, etc.)
      // For simplicity, we'll keep the default order
        break;
    }

    _setState(_state.copyWith(filteredProducts: sortedList));
  }

  Future<void> fetchProducts([String? id, String? type]) async {
    if (_lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!).inMinutes < 15 &&
        _state.products.isNotEmpty) {
      return;
    }

    _setState(_state.copyWith(isLoading: true, error: null));

    try {
      await _apiCallUseCase.fetchEadProducts();
      final allProducts = _eadProductStore.items;

      _setState(_state.copyWith(
        isLoading: false,
        products: allProducts,
        filteredProducts: _filterProducts(allProducts),
      ));

      _lastFetchTime = DateTime.now();
      _getFilterCategoryChips();

    } catch (e) {
      _setState(_state.copyWith(
        isLoading: false,
        error: NetworkFailure(message: e.toString()),
      ));
    }
  }

  _getFilterCategoryChips() {
    if (_state.products.isEmpty) return;

    String categoryId = _state.products.first.categoryId.toString();
    final services = _serviceStore.items
        .where((e) => e.categoryId.toString() == categoryId)
        .toList();

    categories = ['All'];
    categories.addAll(services.map((e) => e.serviceName.toString()).toList());
    notifyListeners();
  }

  // Search services based on query
  void searchServices(String query) {
    _setState(_state.copyWith(
      searchQuery: query,
      filteredProducts: _applySearch(_state.products, query),
    ));
  }

  // Apply search filter to all services
  List<ProductModel> _applySearch(List<ProductModel> productList, String query) {
    if (query.isEmpty) {
      return _filterProducts(productList);
    } else {
      return productList
          .where((service) =>
      service.serviceName.toLowerCase().contains(query.toLowerCase()) ||
          service.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  // Refresh data on demand
  Future<void> refreshData() async {
    _lastFetchTime = null; // Reset last fetch time to force a refresh
    await fetchProducts();
  }

  // Clear search query
  void clearSearch() {
    if (_state.searchQuery.isNotEmpty) {
      _setState(_state.copyWith(
        searchQuery: '',
        filteredProducts: _filterProducts(_state.products),
      ));
    }
    refreshData();
  }

  List<ProductModel> _filterProducts([List<ProductModel>? productList]) {
    final products = productList ?? _state.products;
    List<ProductModel> filtered;

    switch (type) {
      case ProductSearchBy.all:
        filtered = products;
        break;
      case ProductSearchBy.category:
        filtered = products
            .where((element) => element.categoryId.toString() == id)
            .toList();
        break;
      case ProductSearchBy.subCategory:
        filtered = products
            .where((element) => element.subcategoryId.toString() == id)
            .toList();
        break;
      case ProductSearchBy.merchant:
        filtered = products
            .where((element) => element.merchant.id == id)
            .toList();
        break;
      case ProductSearchBy.service:
        filtered = products
            .where((element) => element.serviceId.toString() == id)
            .toList();
        break;
      case ProductSearchBy.search:
        filtered = products
            .where((element) => element.serviceName.toLowerCase().contains(
          _state.searchQuery.toLowerCase(),
        ))
            .toList();
        break;
      case ProductSearchBy.product:
        filtered = products
            .where((element) => element.id.toString() == id)
            .toList();
        break;
    }

    // After applying the main filter, apply any search filter if exists
    return _state.searchQuery.isNotEmpty
        ? _applySearch(filtered, _state.searchQuery)
        : filtered;
  }

  void _setTitle() {
    switch (type) {
      case ProductSearchBy.category:
        _title = _categoryStore.items
            .firstWhereOrNull((element) => element.id.toString() == id)
            ?.title ??
            'Category $id';
        break;
      case ProductSearchBy.subCategory:
        _title = _subCategoryStore.items
            .firstWhereOrNull((element) => element.id.toString() == id)
            ?.name ??
            'Subcategory $id';
        break;
      case ProductSearchBy.service:
        _title = _serviceStore.items
            .firstWhereOrNull((element) => element.id.toString() == id)
            ?.serviceName ??
            'Service $id';
        break;
      case ProductSearchBy.search:
        _title = 'Search Result';
        break;
      case ProductSearchBy.merchant:
        _title = _merchantStore.items
            .firstWhereOrNull((element) => element.id.toString() == id)
            ?.merchant
            .companyName ??
            'Merchant $id';
        break;
      case ProductSearchBy.product:
        _title = _state.products
            .firstWhereOrNull((element) => element.id.toString() == id)
            ?.serviceName ??
            'Product $id';
        break;
      case ProductSearchBy.all:
        _title = 'All Products';
        break;
    }
    notifyListeners();
  }

  void updateFilterByChip(bool selected, int index) {
    String serviceName = categories[index];
    if (serviceName == "All") {
      final filtered = _filterProducts(_state.products);
      _setState(_state.copyWith(filteredProducts: filtered));
      _selectedChipIndex = 0;
      notifyListeners();
      return;
    }

    final ServiceModel service = _serviceStore.items.firstWhere(
          (e) => e.serviceName == serviceName,
    );

    final filtered = _state.products
        .where((element) => element.serviceId.toString() == service.id.toString())
        .toList();

    _setState(_state.copyWith(filteredProducts: filtered));
    _selectedChipIndex = index;
    notifyListeners();
  }

  // Apply distance filter
  void applyDistanceFilter(double maxDistance) {
    // In a real implementation, this would filter products based on distance
    // For now, we'll just apply a placeholder filter
    notifyListeners();
  }

  // Apply price range filter
  void applyPriceRangeFilter(double minPrice, double maxPrice) {
    final filtered = _state.products
        .where((product) =>
    product.planRate >= minPrice &&
        product.planRate <= maxPrice)
        .toList();

    _setState(_state.copyWith(filteredProducts: filtered));
  }

  // Reset all filters
  void resetFilters() {
    _selectedSortOption = 'Recommended';
    _selectedChipIndex = 0;
    final filtered = _filterProducts(_state.products);
    _setState(_state.copyWith(
        searchQuery: '',
        filteredProducts: filtered
    ));
    notifyListeners();
  }
}