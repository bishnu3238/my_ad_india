import 'package:my_ad/core/domain/data_store/data_store.dart';
import 'package:my_ad/core/domain/repository/state_repository.dart';
 import 'package:pack/services/service.dart';

class StateService{

  final StateStore _store;
  final StateRepository  _repository;

  const StateService(this._store, this._repository);


  Future <void> fetchStates() async {
    _store.setStatus(DataStoreStatus.loading);
    final states = await _repository.fetchStates();
    states.fold(
      (failure) => _store.setError(failure.toOperationFailure),
      (result) => _store.setItems(result),
    );
  }
}