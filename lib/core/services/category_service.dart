import '../domain/data_store/data_store.dart';
import '../domain/repository/repository.dart';
import 'package:pack/services/service.dart';

class CategoryService {
  final CategoryStore _store;
  final CategoryRepository _repository;

  const CategoryService(this._store, this._repository);

  Future<void> fetchCategories() async {
    _store.setStatus(DataStoreStatus.loading);

    final result = await _repository.fetchCategories();
    result.fold(
      (failure) => _store.setError(failure.toOperationFailure),
      (categories) => _store.setItems(categories),
    );
  }
}
