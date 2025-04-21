import 'package:my_ad/core/domain/data_store/data_store.dart';
import 'package:my_ad/core/domain/repository/repository.dart';
import 'package:pack/services/base_services/base_service.dart';

class SubcategoryService {
  final SubCategoryStore _store;
  final SubCategoryRepository _repository;

  const SubcategoryService(this._store, this._repository);

  Future<void> fetchSubCategories() async {
    _store.setStatus(DataStoreStatus.loading);
    final subCategories = await _repository.getSubCategories();
    subCategories.fold(
      (failure) => _store.setError(failure.toOperationFailure),
      (result) => _store.setItems(result),
    );
  }
}
