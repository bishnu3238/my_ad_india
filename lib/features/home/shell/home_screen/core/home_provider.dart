import 'dart:developer' as dev;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:my_ad/provider_state/location_provider.dart';
import 'package:provider/provider.dart';
import '../../../../../core/data/api/api_config.dart';
import '../../../../../core/data/model/model.dart';
import '../../../../../core/domain/data_store/data_store.dart';
import 'package:pack/auth/custom_auth.dart';
import 'package:pack/extensions/extensions.dart';
import 'package:pack/services/service.dart';
import '../../../../chat_feature/core/services/socket_services.dart';
import '../../../../../core/domain/use_cases/api_call_use_cases.dart';
import '../../../../../core/injector/dependency_injection.dart';
import '../../../../../provider_state/scroll_visibility_provider.dart';
import '../../../../chat_feature/models/user_status.dart';
import 'home_state.dart';

class HomeScreenProvider extends ChangeNotifier {
  final ApiCallUseCase _apiCallUseCase;
  final ConnectivityService _connectivityService;

  late HomeState state;
  List<ProductModel> nearByProviders = [];

  bool _isLoading = false;
  String? _error;

  // Add a search query field to the state or directly to the provider
  String _searchQuery = '';

  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  HomeScreenProvider(this._apiCallUseCase, this._connectivityService) {
    state = HomeState();
    state.scrollController.addListener(scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.isOnline) {
        fetchData();
      }
    });
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final _ = await Future.wait([
        _apiCallUseCase.fetchBanners(),
        _apiCallUseCase.fetchCategories(),
        _apiCallUseCase.fetchSubCategories(),
        _apiCallUseCase.fetchServices(),
      ]).whenComplete(() {
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      dev.log('Home-Provider: $e');
      notifyListeners();
    }
  }

  Future<List<ProductModel>> fetchNearbyProviders(BuildContext context) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final location = context.read<LocationProvider>();

      if (location.currentLocation.isEmpty) {
        notifyListeners();
        return;
      }
      final locationResponse = await location.detectUserLocation();
      if (locationResponse.isEmpty) return;
      final payload = FetchNearByProductsOfUserPayload(
        latitude: locationResponse.latitude,
        longitude: locationResponse.longitude,
        radius: 5,
        city: location.currentLocation,
      );
      dev.log('Home-Provider: $payload');
      nearByProviders = await _apiCallUseCase.fetchNearbyProviders(payload);
      notifyListeners();
    });

    return nearByProviders;
  }

  void scrollListener() {
    // final ScrollDirection direction =
    //     state.scrollController.position.userScrollDirection;
    // DependencyInjector.get<ScrollVisibilityProvider>().updateVisibility(
    //   direction,
    // );
  }

  checkConnectivity() async {
    await _connectivityService.checkConnectivity();
    state.isOnline = _connectivityService.isConnected;
    notifyListeners();
  }

  setupConnectivityListener() {
    _connectivityService.onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      state.isOnline = result[0] != ConnectivityResult.none;
      if (state.isOnline && (state.isFirstLoad || error != null)) {
        state.isFirstLoad = false;
        fetchData();
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    state.scrollController.removeListener(scrollListener);
    state.scrollController.dispose();
  }

  void setCategory(String id) {
    state = state.copyWith(selectedCategory: id);
    notifyListeners();
  }
}
