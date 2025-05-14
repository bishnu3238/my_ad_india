import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
 import 'package:pack/services/failure/failure.dart';

import '../../../../core/data/model/model.dart';
import '../../../../core/domain/data_store/data_store.dart';
import '../../../../core/domain/repository/repository.dart';
import '../../../../core/services/merchant_dashboard_service.dart';

class SubscriptionPlanProvider extends ChangeNotifier {
  final MerchantDashboardStore merchantStore;
  final SubscriptionPlanRepository _repository;

  final MerchantDashboardStore _dashboardStore;

  SubscriptionPlanProvider({
    required this.merchantStore,
    required SubscriptionPlanRepository repository,
    required MerchantDashboardStore dashboardStore,
  }) : _repository = repository,
       _dashboardStore = dashboardStore;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Failure? _error;
  Failure? get error => _error;

  List<SubscriptionPlanModel> _availablePlans = [];
  List<SubscriptionPlanModel> get availablePlans => _availablePlans;

  MerchantSubscriptionModel? _currentSubscription;
  MerchantSubscriptionModel? get currentSubscription => _dashboardStore.entity?.merchantData.subscription;

  bool _isPlanExpired = false;
  bool get isPlanExpired => _isPlanExpired;

  Future<void> fetchSubscriptionPlans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.getSubscriptionPlans();
    result.fold(
      (failure) {
        _error = failure;
        _isLoading = false;
        notifyListeners();
      },
      (plans) {
        _availablePlans = plans;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> fetchCurrentSubscription() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.getCurrentSubscription(
      '${merchantStore.entity?.merchantData.merchant.id}',
    );
    result.fold(
      (failure) {
        _error = failure;
        _isLoading = false;
        notifyListeners();
      },
      (subscription) {
        _currentSubscription = subscription;
        _isLoading = false;
        checkPlanExpiration();
        notifyListeners();
      },
    );
  }

  void checkPlanExpiration() {
    if (_currentSubscription == null) {
      _isPlanExpired = true;
      notifyListeners();
      return;
    }

    final now = DateTime.now();
    _isPlanExpired =
        now.isAfter(_currentSubscription!.endDate) ||
        _currentSubscription!.planStatus == PlanStatus.expired;
    notifyListeners();
  }

  Future<Either<Failure, MerchantSubscriptionModel>> subscribeToPlan(
    String planId,
  ) async {
    _isLoading = true;
    notifyListeners();

    final result = await _repository.subscribeToPlan(planId);

    _isLoading = false;
    notifyListeners();

    return result;
  }

  bool canAddService() {
    if (_isPlanExpired) {
      return false;
    }

    // Additional checks for service limits could be added here
    return true;
  }
}
