import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:pack/services/service.dart';

import '../../../../../../core/services/service.dart';

class DashboardProvider extends BaseProviderModel {
  final MerchantDashboardService _dashboardService;

  DashboardProvider(this._dashboardService) {
    dev.log('DashboardProvider initialized');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initialFetch();
    });
  }

  Future<void> initialFetch() async {
    setLoading();
    try {
      await Future.wait([
        _dashboardService.fetchMerchantServices(),
        _dashboardService.fetchMerchantPlanAccess(),
      ]);
       setData<bool>(true);
    } catch (e) {
      // Handle error
      dev.log('Error in initialFetch: $e');
      setException(ErrorState.network('$e', retryCallback: initialFetch));
    } finally {
      setData(false);
    }
  }
}
