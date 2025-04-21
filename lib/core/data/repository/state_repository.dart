import 'package:dartz/dartz.dart';
import 'dart:developer' as dev;
import '../api/api_config.dart';
import '../model/city_model.dart';
import '../model/model.dart';
import '../../domain/data_store/data_store.dart';
import '../../domain/repository/state_repository.dart';
import 'package:pack/pack.dart';
 import 'package:pack/services/service.dart';


class StateRepositoryImpl implements StateRepository {
  final ApiCallService _apiCallService;

  StateRepositoryImpl(this._apiCallService);

  @override
  Future<Either<NetworkFailure, List<StateModel>>> fetchStates() async {
    try {
      return await _apiCallService
          .request<List<StateModel>?>(
            config: RequestConfig(
              baseUrl: ApiConfig.baseUrl,
              endpoint: ApiConfig.states,
            ),
            responseConverter: _convertState,
          )
          .then(
            (value) => value.fold(
              (failure) => left(NetworkFailure(message: failure.message)),
              (result) {
                dev.log(result.data.toString());

                if (result.data == null) {
                  left(UnexpectedFailure(message: 'No State found'));
                  return right(result.data!);
                }
                return right(result.data!);
              },
            ),
          );
    } catch (e) {
      '$e'.log;
      throw NetworkFailure(message: e.toString());
    }
  }

  List<StateModel> _convertState(dynamic data) {
    dev.log('EAD-STATE-LISTS = $data');
    if (data is List) {
      return data
          .map<StateModel>(
            (item) => StateModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }
    throw Exception('Invalid response format');
  }
}
