// core/category_services_state.dart
import 'package:flutter/material.dart';
import '../../../../core/data/model/product/service_model.dart';

// Define sort options
enum SortOption {
  nameAsc,
  nameDesc,
  priceLowToHigh,
  priceHighToLow,
}

class CategoryServicesState {
  final bool isLoading;
  final bool isOnline;
  final bool isCheckingConnectivity;
  final String? error;
  final List<ServiceModel> services;
  final bool isSearchActive;
  final String searchQuery;
  final SortOption sortOption;
  final bool showAllServices;
  final ScrollController scrollController;

  const CategoryServicesState({
    this.isLoading = false,
    this.isOnline = true,
    this.isCheckingConnectivity = false,
    this.error,
    this.services = const [],
    this.isSearchActive = false,
    this.searchQuery = '',
    this.sortOption = SortOption.nameAsc,
    this.showAllServices = false,
    required this.scrollController,
  });

  // Helper getters
  int get totalServices => services.length;

  // Show only first 20 services if not viewing all
  List<ServiceModel> get visibleServices => showAllServices
      ? services
      : services.take(20).toList();

  // Determine if we need "View All" button
  bool get shouldShowViewAll => services.length > 20 && !showAllServices;

  // Calculate total item count including "View All" card if needed
  int get visibleItemCount => shouldShowViewAll
      ? visibleServices.length + 1
      : visibleServices.length;

  // Create a new state with updated values
  CategoryServicesState copyWith({
    bool? isLoading,
    bool? isOnline,
    bool? isCheckingConnectivity,
    String? error,
    List<ServiceModel>? services,
    bool? isSearchActive,
    String? searchQuery,
    SortOption? sortOption,
    bool? showAllServices,
    ScrollController? scrollController,
  }) {
    return CategoryServicesState(
      isLoading: isLoading ?? this.isLoading,
      isOnline: isOnline ?? this.isOnline,
      isCheckingConnectivity: isCheckingConnectivity ?? this.isCheckingConnectivity,
      error: error,
      services: services ?? this.services,
      isSearchActive: isSearchActive ?? this.isSearchActive,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
      showAllServices: showAllServices ?? this.showAllServices,
      scrollController: scrollController ?? this.scrollController,
    );
  }
}