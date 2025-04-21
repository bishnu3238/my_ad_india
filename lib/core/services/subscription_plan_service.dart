import '../domain/data_store/data_store.dart';
import '../domain/repository/repository.dart';
import 'package:pack/services/service.dart';

class SubscriptionPlanService{

  final SubscriptionPlanStore _store;
  final SubscriptionPlanRepository _repository;

  const SubscriptionPlanService(this._store, this._repository);


  Future<void> fetchSubscriptionPlans() async {
    _store.setStatus(DataStoreStatus.loading);

    final result = await _repository.getSubscriptionPlans();
    result.fold(
      (failure) => _store.setError(failure.toOperationFailure),
      (subscriptionPlans) => _store.setItems(subscriptionPlans),
    );
  }




}