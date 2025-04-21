import 'package:my_ad/core/data/model/model.dart';
import 'package:pack/services/service.dart';

import '../domain/data_store/referral_store.dart';
import '../domain/repository/referral_repository.dart';

class ReferralService{

  final ReferralStore _store;
  final ReferralRepository _repository;

  const ReferralService(this._store, this._repository);


  Future<void > submitReferralRequest(PostReferralRequest request)async{
    _store.setStatus(DataStoreStatus.loading);
    final result = await _repository.submitReferral(request);
    result.fold(
      (failure) => _store.setError(failure.asOperationFailure),
      (response) => _store.setEntity(ReferralModel.empty()),
    );
  }

}