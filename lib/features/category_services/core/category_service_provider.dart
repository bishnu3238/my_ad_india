// core/category_services_provider.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
 import '../../../../core/data/model/product/service_model.dart';
import '../../../core/domain/data_store/data_store.dart';
import 'category_service_state.dart';

class CategoryServicesProvider extends ChangeNotifier {
  final ServiceStore _serviceStore;
  StreamSubscription? _connectivitySubscription;
  CategoryServicesState _state;

  CategoryServicesProvider({
    required ServiceStore serviceStore,
  }) : _serviceStore = serviceStore,
        _state = CategoryServicesState(
          scrollController: ScrollController(),
        );

  CategoryServicesState get state => _state;

  // Setter for updating state and notifying listeners
  void _setState(CategoryServicesState newState) {
    _state = newState;
    notifyListeners();
  }

  // Connectivity checking
  Future<void> checkConnectivity() async {
    _setState(_state.copyWith(isCheckingConnectivity: true));

    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    _setState(_state.copyWith(
      isOnline: isOnline,
      isCheckingConnectivity: false,
    ));
  }

  // Set up connectivity listener
  Future<void> setupConnectivityListener() async {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      _setState(_state.copyWith(isOnline: result != ConnectivityResult.none));
    });
  }

  // Fetch services for a specific category
  Future<void> fetchCategoryServices(String categoryId) async {
    _setState(_state.copyWith(
      isLoading: true,
      error: null,
    ));

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      // Filter services by category ID
      final allServices = _serviceStore.items;
      final categoryServices = allServices
          .where((service) => service.categoryId.toString() == categoryId)
          .toList();

      // Apply default sorting
      _applySorting(categoryServices, _state.sortOption);

      _setState(_state.copyWith(
        services: categoryServices,
        isLoading: false,
        showAllServices: false,
      ));
    } catch (e) {
      _setState(_state.copyWith(
        isLoading: false,
        error: 'Failed to load services: ${e.toString()}',
      ));
    }
  }

  // Search services
  void searchServices(String query) {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    final allServices = _serviceStore.items;
    final filteredServices = allServices
        .where((service) => service.serviceName.toLowerCase().contains(query.toLowerCase()))
        .toList();

    _applySorting(filteredServices, _state.sortOption);

    _setState(_state.copyWith(
      services: filteredServices,
      isSearchActive: true,
      searchQuery: query,
      showAllServices: true,
    ));
  }

  // Clear search
  void clearSearch() {
    if (!_state.isSearchActive) return;

    // Re-fetch the original category services
    if (_state.services.isNotEmpty) {
      final categoryId = _state.services.first.categoryId.toString();
      fetchCategoryServices(categoryId);
    }

    _setState(_state.copyWith(
      isSearchActive: false,
      searchQuery: '',
    ));
  }

  // Sort services
  void sortServices(SortOption option) {
    final services = List<ServiceModel>.from(_state.services);
    _applySorting(services, option);

    _setState(_state.copyWith(
      services: services,
      sortOption: option,
    ));
  }

  // Apply sorting to a list of services
  void _applySorting(List<ServiceModel> services, SortOption option) {
    switch (option) {
      case SortOption.nameAsc:
        services.sort((a, b) => a.serviceName.compareTo(b.serviceName));
        break;
      case SortOption.nameDesc:
        services.sort((a, b) => b.serviceName.compareTo(a.serviceName));
        break;
      case SortOption.priceLowToHigh:
        services.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighToLow:
        services.sort((a, b) => b.price.compareTo(a.price));
        break;
    }
  }

  // Show all services (when "View All" is clicked)
  void showAllServices() {
    _setState(_state.copyWith(showAllServices: true));
    // Smooth scroll to top
    if (_state.scrollController.hasClients) {
      _state.scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _state.scrollController.dispose();
    super.dispose();
  }
}