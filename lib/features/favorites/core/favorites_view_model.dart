// lib/features/favorites/core/favorites_view_model.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/data/model/model.dart';
import '../../../core/domain/data_store/data_store.dart';
import '../../../core/services/services_service.dart';
import 'favorites_state.dart';

class FavoritesViewModel extends ChangeNotifier {
  final ServicesService _servicesService;
  final ServiceStore _serviceStore;

  FavoritesState _state = const FavoritesInitial();
  final Set<String> _favoriteServiceIds = {};
  static const String FAVORITES_KEY = 'favorite_services';
  static const String FAVORITES_TIMESTAMPS_KEY = 'favorite_timestamps';

  Map<String, DateTime> _favoriteTimestamps = {};

  FavoritesViewModel(this._servicesService, this._serviceStore) {
    _loadFavorites();
  }

  FavoritesState get state => _state;
  Set<String> get favoriteServiceIds => _favoriteServiceIds;

  Future<void> loadFavorites() async {
    _state = const FavoritesLoading();
    notifyListeners();

    try {
      await _loadFavorites();
      await _servicesService.fetchServices();

      final allServices = _serviceStore.items;
      final favoriteServices = allServices
          .where((service) => _favoriteServiceIds.contains(service.id))
          .toList();

      if (favoriteServices.isEmpty) {
        _state = const FavoritesEmpty();
      } else {
        // Sort by date added by default
        _sortServices(favoriteServices, FavoritesSortOption.dateAdded);

        _state = FavoritesLoaded(
          favoriteServices: favoriteServices,
          filteredServices: favoriteServices,
        );
      }
    } catch (e) {
      _state = FavoritesError('Failed to load favorites. Please try again.');
      if (kDebugMode) {
        print('Error loading favorites: $e');
      }
    }

    notifyListeners();
  }

  void searchFavorites(String query) {
    if (_state is FavoritesLoaded) {
      final currentState = _state as FavoritesLoaded;

      if (query.isEmpty) {
        _state = currentState.copyWith(
          filteredServices: currentState.favoriteServices,
          searchQuery: '',
        );
      } else {
        final filteredServices = currentState.favoriteServices
            .where((service) =>
        service.serviceName.toLowerCase().contains(query.toLowerCase()) ||
            service.description.toLowerCase().contains(query.toLowerCase()))
            .toList();

        _state = currentState.copyWith(
          filteredServices: filteredServices,
          searchQuery: query,
        );
      }
      notifyListeners();
    }
  }

  void sortFavorites(FavoritesSortOption sortOption) {
    if (_state is FavoritesLoaded) {
      final currentState = _state as FavoritesLoaded;
      final sortedServices = List<ServiceModel>.from(currentState.filteredServices);

      _sortServices(sortedServices, sortOption);

      _state = currentState.copyWith(
        filteredServices: sortedServices,
        sortOption: sortOption,
      );
      notifyListeners();
    }
  }

  void _sortServices(List<ServiceModel> services, FavoritesSortOption sortOption) {
    switch (sortOption) {
      case FavoritesSortOption.dateAdded:
        services.sort((a, b) {
          final timestampA = _favoriteTimestamps[a.id] ?? DateTime.now();
          final timestampB = _favoriteTimestamps[b.id] ?? DateTime.now();
          return timestampB.compareTo(timestampA); // Most recent first
        });
        break;
      case FavoritesSortOption.alphabetical:
        services.sort((a, b) => a.serviceName.compareTo(b.serviceName));
        break;
      case FavoritesSortOption.priceHighToLow:
        services.sort((a, b) => b.price.compareTo(a.price));
        break;
      case FavoritesSortOption.priceLowToHigh:
        services.sort((a, b) => a.price.compareTo(b.price));
        break;
    }
  }

  void toggleViewMode() {
    if (_state is FavoritesLoaded) {
      final currentState = _state as FavoritesLoaded;
      _state = currentState.copyWith(isGridView: !currentState.isGridView);
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String serviceId) async {
    if (_favoriteServiceIds.contains(serviceId)) {
      _favoriteServiceIds.remove(serviceId);
      _favoriteTimestamps.remove(serviceId);

      // Update current state if needed
      if (_state is FavoritesLoaded) {
        final currentState = _state as FavoritesLoaded;
        final updatedFavorites = currentState.favoriteServices
            .where((service) => service.id != serviceId)
            .toList();

        final updatedFiltered = currentState.filteredServices
            .where((service) => service.id != serviceId)
            .toList();

        if (updatedFavorites.isEmpty) {
          _state = const FavoritesEmpty();
        } else {
          _state = currentState.copyWith(
            favoriteServices: updatedFavorites,
            filteredServices: updatedFiltered,
          );
        }
      }
    } else {
      _favoriteServiceIds.add(serviceId);
      _favoriteTimestamps[serviceId] = DateTime.now();
    }

    await _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(String serviceId) {
    return _favoriteServiceIds.contains(serviceId);
  }

  Future<void> clearAllFavorites() async {
    _favoriteServiceIds.clear();
    _favoriteTimestamps.clear();
    await _saveFavorites();
    _state = const FavoritesEmpty();
    notifyListeners();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favList = prefs.getStringList(FAVORITES_KEY) ?? [];
      final timestampsJson = prefs.getStringList(FAVORITES_TIMESTAMPS_KEY) ?? [];

      _favoriteServiceIds.addAll(favList);

      // Load timestamps
      for (String timestampEntry in timestampsJson) {
        final parts = timestampEntry.split(':');
        if (parts.length == 2) {
          final serviceId = parts[0];
          final timestamp = DateTime.fromMillisecondsSinceEpoch(int.parse(parts[1]));
          _favoriteTimestamps[serviceId] = timestamp;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading favorites: $e');
      }
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(FAVORITES_KEY, _favoriteServiceIds.toList());

      // Save timestamps
      final timestampsJson = _favoriteTimestamps.entries
          .map((entry) => '${entry.key}:${entry.value.millisecondsSinceEpoch}')
          .toList();
      await prefs.setStringList(FAVORITES_TIMESTAMPS_KEY, timestampsJson);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving favorites: $e');
      }
    }
  }

  Future<void> refreshFavorites() async {
    await loadFavorites();
  }
}