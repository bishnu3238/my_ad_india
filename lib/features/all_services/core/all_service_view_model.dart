// lib/features/services/presentation/state/service_list_view_model.dart

import 'package:flutter/foundation.dart';
import 'package:my_ad/core/services/services_service.dart';
import 'package:my_ad/features/all_services/core/all_services_route.dart';
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

  String _selectedCategory = '';
  ShowServicesBy _searchBy = ShowServicesBy.all;

  ServiceListViewModel(this._service, this._serviceStore) {
    _loadFavorites();
  }

  String get selectedCategoryId => _selectedCategory;
  ShowServicesBy get searchBy => _searchBy;
  set selectedCategoryId(String value) {
    _selectedCategory = value;
    notifyListeners();
  }

  set searchBy(ShowServicesBy value) {
    _searchBy = value;
    notifyListeners();
  }

  ServiceListState get state => _state;
  Set<String> get favoriteServices => _favoriteServices;

  Future<void> fetchServices(
    ShowServicesBy showServiceBy,
    String categoryId,
  ) async {
    searchBy = showServiceBy;
    selectedCategoryId = categoryId;
    // Reset state to loading
    _state = const ServiceListLoading();
    notifyListeners();

    try {
      List<ServiceModel> services = [];
      // Use the service to fetch data

      await _service.fetchServices();
      services = _serviceStore.items;

      // Extract categories
      final Set<String> categorySet = {'All'};
      String? categoryName;
      for (var service in services) {
        if (service.categoryName != null) {
          if ('${service.categoryId}' == categoryId) {
            categoryName = service.categoryName;
          }
          categorySet.add(service.categoryName!);
        }
      }
      final String selectedCategory = categorySet.firstWhere(
        (e) => e == categoryName,
        orElse: () => 'All',
      );
      List<ServiceModel> filtered = [];
      if (categoryId.isNotEmpty && searchBy == ShowServicesBy.category) {
        filtered =
            services.where((e) => '${e.categoryId}' == categoryId).toList();
      } else if (categoryId.isNotEmpty &&
          searchBy == ShowServicesBy.subCategory) {
        filtered =
            services.where((e) => '${e.subcategoryId}' == categoryId).toList();
      } else if (categoryId.isNotEmpty && searchBy == ShowServicesBy.all) {
        filtered = services;
      }

      _state = ServiceListLoaded(
        services: filtered,
        categories: categorySet.toList(),
        selectedCategory: selectedCategory,
      );

      // Access services from the store after fetching
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
      final filteredServices =
          _serviceStore.items
              .where(
                (service) =>
                    service.serviceName.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    (service.description.isNotEmpty &&
                        service.description.toLowerCase().contains(
                          query.toLowerCase(),
                        )),
              )
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

      final filteredServices =
          category == 'All'
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
      final List<ServiceModel> sortedServices = List.from(
        currentState.services,
      );

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
    await fetchServices(searchBy, selectedCategoryId);
  }
}

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
