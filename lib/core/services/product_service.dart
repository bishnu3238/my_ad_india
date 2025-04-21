import '../data/model/model.dart';
import '../domain/data_store/data_store.dart';
import '../domain/repository/repository.dart';
import 'package:pack/services/service.dart';

class ProductService {
  final ProductStore _store;
  final ProductRepository _repository;

  const ProductService(this._store, this._repository);

  Future<void> fetchProducts() async {
    _store.setStatus(DataStoreStatus.loading);

    final result = await _repository.fetchEadProducts();
    result.fold(
      (failure) => _store.setError(OperationFailure(message: failure.message)),
      (products) => _store.setItems(products),
    );
  }

  Future<List<ProductModel>> fetchProductsByCategory(String categoryId) async{
    /// TODO: this is for local or fast approach;
    // return _store.items.where((e) => '${e.categoryId}' == categoryId).toList();
    /// OR
    /// TODO: call a api
    return await _repository.fetchProductsByCategory(categoryId).then((value)=>value.getRight());

  }
}
