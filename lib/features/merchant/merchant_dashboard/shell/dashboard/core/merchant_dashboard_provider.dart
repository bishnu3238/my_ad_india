import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:my_ad/core/data/model/customer_visit_model.dart';
import 'package:my_ad/core/data/model/model.dart';
import 'package:pack/services/service.dart';

import '../../../../../../core/data/model/merchant/merchant_service_model.dart';
import '../../../../../../core/domain/data_store/data_store.dart';
import '../../../../../../core/services/service.dart';

class DashboardProvider extends BaseProviderModel {
  final MerchantDashboardService _dashboardService;
  final MerchantDashboardStore _dashboardStore;
  final CustomerVisitService _customerVisitService;

  DashboardProvider(
    this._dashboardService,
    this._dashboardStore,
    this._customerVisitService,
  ) {
    dev.log('DashboardProvider initialized');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initialFetch();
    });
  }

  List<CustomerVisit> _visits = [];

  List<CustomerVisit> get visits => _visits;
  int get merchantId => _dashboardStore.merchantId;
  set visits(List<CustomerVisit> value) {
    _visits = value;
    notifyListeners();
  }

  List<MerchantServiceModel> get services =>
      _dashboardStore.entity?.services ?? [];

  Future<void> initialFetch() async {
    setLoading();
    try {
      await Future.wait([
        _dashboardService.fetchMerchantServices(),
        _dashboardService.fetchMerchantPlanAccess(),
      ]);
      await _customerVisitService
          .getMerchantVisits(_dashboardStore.merchantId)
          .then((value) {
            visits = value.data!;
          });

      setData<bool>(true);
    } catch (e) {
      // Handle error
      dev.log('Error in initialFetch: $e');
      setException(ErrorState.network('$e', retryCallback: initialFetch));
    } finally {
      setData(false);
    }
  }


  void deleteMerchantService()async{
    setLoading();
    try {
      final serviceId = _dashboardStore.entity?.services.first.id.toString();
      final merchantId = _dashboardStore.merchantId.toString();
      final service = _dashboardStore.entity?.services.first;
      final payload = DeleteMerchantServicePayload(serviceId: serviceId!,service: service!, requestType: ServiceRequestType.delete, merchantId: merchantId );
      await _dashboardService.deleteMerchantService(payload);
      setData<bool>(true);
    } catch (e) {
      // Handle error
      dev.log('Error in deleteMerchantService: $e');
      setException(ErrorState.network('$e', retryCallback: deleteMerchantService));
    } finally {
      setData(false);
    }
  }


  updateStore(MerchantDashboardStore value) {
    notifyListeners();
    return this;
  }
}
