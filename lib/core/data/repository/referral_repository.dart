import 'dart:convert';
import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';

import 'package:my_ad/core/data/model/request/POST/post_referral_request.dart';
import 'package:my_ad/core/data/model/response/referral_response.dart';

import 'package:pack/services/failure/failure.dart';
import 'package:pack/services/service.dart';

import '../../domain/repository/referral_repository.dart';
import '../api/api_config.dart';

class ReferralRepositoryImpl implements ReferralRepository {
  final ApiCallService apiService;

  ReferralRepositoryImpl({required this.apiService});

  @override
  Future<void> createReferral(String referralCode) {
    // TODO: implement createReferral
    throw UnimplementedError();
  }

  @override
  Future<void> getReferralDetails(String referralCode) {
    // TODO: implement getReferralDetails
    throw UnimplementedError();
  }

  @override
  Future<void> redeemReferral(String referralCode) {
    // TODO: implement redeemReferral
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, ReferralResponse>> submitReferral(
    PostReferralRequest request,
  ) async {
    try {
      final config = RequestConfig(
        baseUrl: ApiConfig.baseUrl,
        endpoint: ApiConfig.referralSubmit,
        body: request.toJson(),
        method: RequestMethod.post,
      );

      final response = await apiService.request<ReferralResponse>(
        config: config,
        responseConverter: (data) => ReferralResponse.fromJson(data),
      );

      return response.fold(
        (failure) => left(failure),
        (result) => result.data!.when(
          success: (status, message, timestamp) {
            dev.log('Referral submitted successfully: $message');
            return right(result.data!);
          },
          error: (status, message, data, timestamp) {
            dev.log('Referral submission error: $message');
            throw UnexpectedFailure(message: message, code: '$status');
          },
        ),
      );
    } catch (e) {
      return Left(NetworkFailure(message: e.toString()));
    }
  }
}
