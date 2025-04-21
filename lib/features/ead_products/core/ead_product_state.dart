import 'package:pack/services/service.dart';

import '../../../core/data/model/model.dart';

class ProductState {
  final bool isLoading;
  final bool isSearchBarVisible;
  final String searchQuery;
  final NetworkFailure? error;
  final List<ProductModel> products;
  final List<ProductModel> filteredProducts;

  const ProductState({
    this.isLoading = false,
    this.isSearchBarVisible = true,
    this.searchQuery = '',
    this.error,
    this.products = const [],
    this.filteredProducts = const [],
  });

  ProductState copyWith({
    bool? isLoading,
    bool? isSearchBarVisible,
    String? searchQuery,
    NetworkFailure? error,
    List<ProductModel>? products,
    List<ProductModel>? filteredProducts,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      isSearchBarVisible: isSearchBarVisible ?? this.isSearchBarVisible,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error ?? this.error,
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
    );
  }
}