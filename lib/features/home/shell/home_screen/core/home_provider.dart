import 'dart:developer' as dev;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pack/services/service.dart';
import '../../../../../core/domain/use_cases/api_call_use_cases.dart';
import '../../../../../core/injector/dependency_injection.dart';
import '../../../../../provider_state/scroll_visibility_provider.dart';
import 'home_state.dart';

class HomeScreenProvider extends ChangeNotifier {
  final ApiCallUseCase _apiCallUseCase;
  final ConnectivityService _connectivityService;

     late HomeState state;

  bool _isLoading = false;
  String? _error;

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

  void scrollListener() {
    final ScrollDirection direction =
        state.scrollController.position.userScrollDirection;
    DependencyInjector.get<ScrollVisibilityProvider>().updateVisibility(
      direction,
    );
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
   state =  state.copyWith(selectedCategory: id);
    notifyListeners();
  }
}
