import 'dart:developer' as dev;

import 'package:pack/services/base_services/base_service.dart';

import '../data/model/model.dart';
import '../domain/data_store/data_store.dart';
import '../domain/repository/repository.dart';

class ServicesService {
  final ServiceStore _store;
  final ServiceRepository _repository;

  ServicesService(this._store, this._repository);

  Future<void> fetchServices() async {
    _store.setStatus(DataStoreStatus.loading);
    try {
      final result = await _repository.fetchServices();

      result.fold(
        (failure) =>
            _store.setError(OperationFailure(message: failure.message)),
        (services) => _store.setItems(services),
      );
    } catch (e) {
      dev.log('SERVICES-SERVICES-ERROR: $e');
    }
  }

  Future<List<ServiceModel>?> fetchServicesByCategoryId(String id) async {
    _store.setStatus(DataStoreStatus.loading);
    try {
      final result = await _repository.fetchServicesByCategory(id);

      return result.fold((failure) {
        _store.setError(OperationFailure(message: failure.message));
        return null;
      }, (services) => services);
    } catch (e) {
      dev.log('SERVICES-SERVICES-ERROR: $e');
    }
    return null;
  }
}
