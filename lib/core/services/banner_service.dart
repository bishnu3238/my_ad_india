import 'package:my_ad/core/domain/data_store/data_store.dart';
import 'package:pack/services/base_services/base_service.dart';

import '../domain/repository/repository.dart';

class BannerService {
  final BannerStore _store;
  final BannerRepository _repository;

  const BannerService(this._store, this._repository);

  Future<void> fetchBanners() async {
    _store.setStatus(DataStoreStatus.loading);

    final result = await _repository.getBanners();
    result.fold(
      (failure) => _store.setError(failure.toOperationFailure),
      (banners) => _store.setItems(banners),
    );
  }
}
