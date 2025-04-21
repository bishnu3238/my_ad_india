import '../domain/data_store/data_store.dart';
import '../domain/repository/repository.dart';
import 'package:pack/services/service.dart';

class CityService {
  final CitiesStore _store;
  final CitiesRepository _repository;

  const CityService(this._store, this._repository);

  Future<void> fetchCities() async {
    try {
      final cities = await _repository.fetchCities();
      cities.fold(
        (error) => _store.setError(error.toOperationFailure),
        (data) => _store.setItems(data),
      );
    } catch (e) {
      _store.setError(OperationFailure(message: e.toString()));
      // Handle error
    }
  }
}
