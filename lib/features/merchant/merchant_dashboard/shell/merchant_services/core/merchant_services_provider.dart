import 'package:flutter/material.dart';
import 'package:my_ad/core/domain/data_store/merchant_dashboard_store.dart';

import 'package:pack/services/service.dart';

import '../../../../../../core/data/model/model.dart';
import '../../../../../../core/services/service.dart';
import '../../../../core/merchant_auth_provider.dart';

class MerchantServicesProvider extends BaseProviderModel {
  MerchantData merchantData;
  final MerchantDashboardService planRestrictionService;

  MerchantServicesProvider({
    required this.merchantData,
    required this.planRestrictionService,
  }) {
    _merchantModel = merchantData.merchant ?? MerchantModel.empty();
    _subscriptionModel =
        merchantData.subscription ?? MerchantSubscriptionModel.empty();
    _initialize();
  }

  late MerchantModel _merchantModel;
  MerchantModel get merchantModel => _merchantModel;

  late MerchantSubscriptionModel _subscriptionModel;
  MerchantSubscriptionModel get subscriptionModel => _subscriptionModel;

  List<MerchantServiceModel> _services = [];
  List<MerchantServiceModel> get services => _services;
  bool get hasServices => _services.isNotEmpty;

  MerchantPlanAccessModel? _planAccess;
  MerchantPlanAccessModel? get planAccess => _planAccess;

  PlanFeatureManager? _featureManager;
  PlanFeatureManager? get featureManager => _featureManager;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  NetworkFailure? _error;
  NetworkFailure? get error => _error;
  bool get hasError => _error != null;

  // Plan restriction getters
  bool get canAddMoreServices => _featureManager?.canAddMoreServices ?? false;
  int get remainingServices => _featureManager?.remainingServices ?? 0;
  int get remainingUpdates => _featureManager?.remainingUpdates ?? 0;
  DateTime get validUntil => _planAccess?.validUntil ?? DateTime.now();

  // Additional plan feature getters
  int get maxPhotoCount => _featureManager?.maxPhotoCount ?? 0;
  int get maxDescriptionLength => _featureManager?.maxDescriptionLength ?? 0;
  bool get isVideoAllowed => _featureManager?.isVideoAllowed ?? false;
  int get maxVideoLength => _featureManager?.maxVideoLength ?? 0;
  bool get canShowReviews => _featureManager?.canShowReviews ?? false;
  bool get canShowOffers => _featureManager?.canShowOffers ?? false;

  Future<void> _initialize() async {
    await Future.wait([_fetchServices(), _fetchPlanAccess()]);
  }

  Future<void> _fetchServices() async {
    if (_merchantModel.id == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await planRestrictionService.fetchMerchantServices();

      // result.fold(
      //   (failure) {
      //     _error = failure;
      //     debugPrint('Failed to fetch services: ${failure.message}');
      //   },
      //   (response) {
      //     _services = response.services;
      //   },
      // );
    } catch (e) {
      _error = NetworkFailure(message: e.toString());
      debugPrint('Error fetching services: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchPlanAccess() async {
    if (_merchantModel.id == null) return;

    try {
      final result = await planRestrictionService.fetchMerchantPlanAccess();

      // result.fold(
      //   (failure) {
      //     debugPrint('Failed to fetch plan access: ${failure.message}');
      //   },
      //   (planAccess) {
      //     _planAccess = planAccess;
      //     _featureManager = PlanFeatureManager(planAccess);
      //   },
      // );
    } catch (e) {
      debugPrint('Error fetching plan access: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _initialize();
  }

  Future<void> deleteService(int serviceId) async {
    if (_merchantModel.id == null) return;

    _isLoading = true;
    notifyListeners();

    final request = SubmitServiceRequest(
      merchantId: '${_merchantModel.id}',
      requestType: ServiceRequestType.delete,
      service: MerchantServiceModel.empty(),
    );
    try {
      final result = await planRestrictionService.submitServiceRequest(request);

      // return result.fold(
      //   (failure) {
      //     _error = failure;
      //     debugPrint('Failed to delete service: ${failure.message}');
      //     return false;
      //   },
      //   (_) {
      //     // Remove from local list
      //     _services.removeWhere((service) => service.id == serviceId);
      //     // Refresh plan access to update remaining services count
      //     _fetchPlanAccess();
      //     return true;
      //   },
      // );
    } catch (e) {
      _error = NetworkFailure(message: e.toString());
      debugPrint('Error deleting service: $e');
      return;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  MerchantServicesProvider updateStore(MerchantDashboardStore store) {
    if (store.entity != store.entity) {
      merchantData = store.entity!.merchantData;
    }
    return this;
  }
}
