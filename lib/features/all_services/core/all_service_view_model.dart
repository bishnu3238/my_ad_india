// lib/features/services/presentation/state/service_list_view_model.dart

import 'package:flutter/foundation.dart';
import 'package:my_ad/core/services/services_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/data/model/model.dart';
import '../../../core/domain/data_store/data_store.dart';
import 'service_list_state.dart';

class ServiceListViewModel extends ChangeNotifier {
  final ServicesService _service;
  final ServiceStore _serviceStore;
  ServiceListState _state = const ServiceListInitial();
  final Set<String> _favoriteServices = {};
  static const String FAVORITES_KEY = 'favorite_services';

  ServiceListViewModel(this._service, this._serviceStore) {
    _loadFavorites();
  }

  ServiceListState get state => _state;
  Set<String> get favoriteServices => _favoriteServices;

  // Future<void> fetchServices() async {
  //   _state = const ServiceListLoading();
  //   notifyListeners();
  //
  //   try {
  //     // Fetch services
  //     await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
  //     final services = _serviceStore.items;
  //
  //     // Extract categories
  //     final Set<String> categorySet = {'All'};
  //     for (var service in services) {
  //       if (service.categoryName != null) {
  //         categorySet.add(service.categoryName!);
  //       }
  //     }
  //
  //     _state = ServiceListLoaded(
  //       services: services,
  //       categories: categorySet.toList(),
  //       selectedCategory: 'All',
  //     );
  //   } catch (e) {
  //     _state = ServiceListError('Failed to load services. Please try again.');
  //     if (kDebugMode) {
  //       print('Error fetching services: $e');
  //     }
  //   }
  //
  //   notifyListeners();
  // }
  Future<void> fetchServices() async {
    _state = const ServiceListLoading();
    notifyListeners();

    try {
      // Use the service to fetch data
      await _service.fetchServices();

      // Access services from the store after fetching
      final services = _serviceStore.items;

      // Extract categories
      final Set<String> categorySet = {'All'};
      for (var service in services) {
        if (service.categoryName != null) {
          categorySet.add(service.categoryName!);
        }
      }

      _state = ServiceListLoaded(
        services: services,
        categories: categorySet.toList(),
        selectedCategory: 'All',
      );
    } catch (e) {
      _state = ServiceListError('Failed to load services. Please try again.');
      if (kDebugMode) {
        print('Error fetching services: $e');
      }
    }

    notifyListeners();
  }
  void searchServices(String query) {
    if (_state is ServiceListLoaded) {
      final currentState = _state as ServiceListLoaded;

      // Filter services based on search query
      final filteredServices = _serviceStore.items
          .where((service) =>
      service.serviceName.toLowerCase().contains(query.toLowerCase()) ||
          (service.description.isNotEmpty &&
              service.description.toLowerCase().contains(query.toLowerCase())))
          .toList();

      _state = currentState.copyWith(
        services: query.isEmpty ? _serviceStore.items : filteredServices,
        searchQuery: query,
      );
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    if (_state is ServiceListLoaded) {
      final currentState = _state as ServiceListLoaded;

      final filteredServices = category == 'All'
          ? _serviceStore.items
          : _serviceStore.items
          .where((service) => service.categoryName == category)
          .toList();

      _state = currentState.copyWith(
        services: filteredServices,
        selectedCategory: category,
      );
      notifyListeners();
    }
  }

  void sortServices(SortOption option) {
    if (_state is ServiceListLoaded) {
      final currentState = _state as ServiceListLoaded;
      final List<ServiceModel> sortedServices = List.from(currentState.services);

      switch (option) {
        case SortOption.popularity:
        // In a real app, this would use actual popularity metrics
          break;
        case SortOption.priceHighToLow:
          sortedServices.sort((a, b) => b.price.compareTo(a.price));
          break;
        case SortOption.priceLowToHigh:
          sortedServices.sort((a, b) => a.price.compareTo(b.price));
          break;
        case SortOption.newest:
        // In a real app, this would sort by creation date
          break;
      }

      _state = currentState.copyWith(
        services: sortedServices,
        sortOption: option,
      );
      notifyListeners();
    }
  }

  void toggleFavorite(String serviceId) {
    if (_favoriteServices.contains(serviceId)) {
      _favoriteServices.remove(serviceId);
    } else {
      _favoriteServices.add(serviceId);
    }
    _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(String serviceId) {
    return _favoriteServices.contains(serviceId);
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favList = prefs.getStringList(FAVORITES_KEY) ?? [];
      _favoriteServices.addAll(favList);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading favorites: $e');
      }
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(FAVORITES_KEY, _favoriteServices.toList());
    } catch (e) {
      if (kDebugMode) {
        print('Error saving favorites: $e');
      }
    }
  }

  Future<void> retryFetch() async {
    await fetchServices();
  }
}