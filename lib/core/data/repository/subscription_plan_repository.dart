import 'package:dartz/dartz.dart';
import 'dart:developer' as dev;

 import '../../domain/repository/subscription_plan_repository.dart';
import 'package:pack/services/service.dart';

import '../api/api_config.dart';
import '../model/model.dart';

class SubscriptionPlanRepositoryImpl implements SubscriptionPlanRepository {
  final ApiCallService _apiCallService;

  SubscriptionPlanRepositoryImpl(
    this._apiCallService,
  );

  @override
  Future<Either<NetworkFailure, List<SubscriptionPlanModel>>>
  getSubscriptionPlans() async {
    return await _apiCallService
        .request<SubscriptionPlanResponse?>(
          config: RequestConfig(
            baseUrl: ApiConfig.baseUrl,
            endpoint: ApiConfig.plans,
            method: RequestMethod.get,
          ),
          responseConverter: (data) {
            dev.log(data.toString());
            dev.log('${data.runtimeType}');
            dev.log('ROW API RESPONSE $data');

            return SubscriptionPlanResponse.fromJson(data);
          },
        )
        .then(
          (value) => value.fold(
            (failure) => left(NetworkFailure(message: failure.message)),
            (response) {
              dev.log("RESPONSE : ${response.data!.plans}");
              if (response.data!.success) {
                 return right(response.data!.plans);
              } else {
                return left(
                  NetworkFailure(
                    message:
                        'Failed to fetch plans: ${response.data!.count} plans found, but success is false',
                  ),
                );
              }
            },
          ),
        );
  }

  List<SubscriptionPlanModel>? convertSubscriptionPlanModel(json) {
    if (json is List) {
      return json.map((json) => SubscriptionPlanModel.fromJson(json)).toList();
    }
    return null;
  }

  @override
  Future<Either<NetworkFailure, MerchantSubscriptionModel>>
  getCurrentSubscription(String merchantId) async {

    final config = RequestConfig(
      baseUrl: ApiConfig.baseUrl,
      endpoint: ApiConfig.merchantService,
      method: RequestMethod.post,
      queryParameters: {'action': 'get_merchant_subscription'},
      body: {'merchant_id': merchantId},
    );
    return await _apiCallService
        .request(
          config: config,
          responseConverter: (data) {

            dev.log('get_merchant_subscription: $data');

            return MerchantSubscriptionModel.fromJson(data)
            ;
          },
        )
        .then((value) {
          return value.fold(
            (failure) => left(NetworkFailure(message: failure.message)),
            (response) => right(response.data!),
          );
        });
  }

  @override
  Future<Either<NetworkFailure, MerchantSubscriptionModel>> subscribeToPlan(
    String planId,
  ) async {
    // if (!await _networkInfo.isConnected) {
    //   return left(NetworkFailure(message: 'No Internet Connection'));
    // }
    final config = RequestConfig(
      baseUrl: ApiConfig.baseUrl,
      endpoint: ApiConfig.merchantService,
      method: RequestMethod.post,
      queryParameters: {'action': 'subscribe_to_plan'},
      body: {'plan_id': planId},
    );
    return await _apiCallService
        .request(
          config: config,
          responseConverter: (data) => MerchantSubscriptionModel.fromJson(data),
        )
        .then((value) {
          return value.fold(
            (failure) => left(NetworkFailure(message: failure.message)),
            (response) => right(response.data!),
          );
        });
  }

  @override
  String get repositoryName => 'SubscriptionPlanRepositoryImpl';
}
