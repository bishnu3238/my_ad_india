import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'dart:developer' as dev;
import 'package:pack/services/service.dart';

import '../../domain/data_store/data_store.dart';
import '../../domain/repository/repository.dart';
import '../api/api_config.dart';
import '../model/model.dart';

class MerchantAuthRepositoryImpl implements MerchantAuthRepository {
  final ApiCallService _apiService;

  MerchantAuthRepositoryImpl(this._apiService);

  @override
  Future<Either<NetworkFailure, MerchantRegistrationResponse>> registration(
    MerchantRegistrationPayload request,
  ) async {
    try {
      final response = await _apiService.request<MerchantRegistrationResponse>(
        config: RequestConfig(
          baseUrl: ApiConfig.baseUrl,
          endpoint: ApiConfig.merchantRegister,
          queryParameters: {'action': 'register'},
          method: RequestMethod.post,
          body: jsonEncode(request.toJson()),
        ),
        responseConverter:
            (data) => MerchantRegistrationResponse.fromJson(data),
      );

      return response.fold(
        (failure) => left(failure),
        (result) => right(result.data!),
      );
    } catch (e) {
      dev.log('MERCHANT-AUTH-REPOSITORY-IMPL-REGISTRATION-ERROR: $e');
      return left(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<NetworkFailure, MerchantLoginResponse>> login(
    PostMerchantLogin request,
  ) async {
    try {
      final response = await _apiService.request<MerchantLoginResponse>(
        config: RequestConfig(
          baseUrl: ApiConfig.baseUrl,
          endpoint: ApiConfig.merchantLogin,
          body: jsonEncode(request.toJson()),
          method: RequestMethod.post,
          responseFormat: ResponseFormat.json,
          timeout: const Duration(seconds: 30),
          headers: {"Content-Type": "application/json"},
        ),
        responseConverter: (data) => MerchantLoginResponse.fromJson(data),
      );

      return response.fold(
        (failure) => left(failure),
        (result) => result.data!.when(
          success: (status, message, data, timestamp) {
            return right(result.data!);
          },
          otpRequired: (status, message, data, timestamp) {
             return right(result.data!);
          },
          error: (status, message, data, timestamp) {
            return Left(
              NetworkFailure(
                message: message,
                statusCode: status,
                data: data,
                type: NetworkErrorType.unknown,
              ),
            );
          },
        ),
      );
    } catch (e) {
      dev.log('MERCHANT-AUTH-REPOSITORY-IMPL-LOGIN-ERROR: $e');
      throw NetworkFailure(message: e.toString());
    }
  }

  @override
  Future<Either<NetworkFailure, MerchantOtpVerificationResponse>> verifyOTP(
    PostMerchantOtpVerification request,
  ) async {
    try {
      final response = await _apiService
          .request<MerchantOtpVerificationResponse>(
            config: RequestConfig(
              baseUrl: ApiConfig.baseUrl,
              endpoint: ApiConfig.merchantOtp,
              body: jsonEncode(request.toJson()),
              method: RequestMethod.post,
              queryParameters: {'action': 'verify'},
            ),
            responseConverter:
                (data) => MerchantOtpVerificationResponse.fromJson(data),
          );

      return response.fold(
        (failure) => left(failure),
        (result) => right(result.data!),
      );
    } catch (e) {
      dev.log('MERCHANT-AUTH-REPOSITORY-IMPL-VERIFY-OTP-ERROR: $e');
      return left(
        NetworkFailure(message: 'Unexpected error during OTP verification: $e'),
      );
    }
  }

  @override
  Future<Either<NetworkFailure, bool>> resendOTP(String merchantId) async {
    final request = PostMerchantResendOtp(merchantId: merchantId);
    final config = RequestConfig(
      baseUrl: ApiConfig.baseUrl,
      endpoint: ApiConfig.merchantResendOtp,
      method: RequestMethod.post,
      body: jsonEncode(request.toJson()),
      queryParameters: {'action': 'resend'},
    );

    try {
      final response = await _apiService.request(
        config: config,
        responseConverter: (data) {
          // Log the response for debugging
          dev.log('RESEND OTP RESPONSE: $data');

          // Check if the response contains an OTP
          if (data is Map<String, dynamic> &&
              data.containsKey('data') &&
              data['data'] is Map<String, dynamic> &&
              data['data'].containsKey('otp')) {
            final otp = data['data']['otp'].toString();
            dev.log('NEW OTP: $otp');
          }

          return data;
        },
      );

      return response.fold((failure) => left(failure), (result) {
        final data = result.data;

        // Check if the response is successful
        if (data is Map<String, dynamic> &&
            data.containsKey('status') &&
            (data['status'] == 200 || data['status'] == 201)) {
          return right(true);
        }

        // If response is not successful, return a failure
        return left(
          NetworkFailure(
            message:
                data is Map<String, dynamic> && data.containsKey('message')
                    ? data['message'].toString()
                    : 'Failed to resend OTP',
          ),
        );
      });
    } catch (e) {
      dev.log('MERCHANT-AUTH-REPOSITORY-IMPL-RESEND-OTP-ERROR: $e');
      return left(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<NetworkFailure, bool>> verifyMobileNumber(String mobile) async {
    final config = RequestConfig(
      baseUrl: ApiConfig.baseUrl,
      endpoint: ApiConfig.merchantVerifyMobile,
      method: RequestMethod.post,
      body: jsonEncode({'mobile': mobile}),
      queryParameters: {'action': 'check'},
    );

    try {
      final response = await _apiService.request(
        config: config,
        responseConverter: (data) => data,
      );

      return response.fold((failure) => left(failure), (result) {
        dev.log('QUESTION: IS PHONE NO VERIFIED? ${result.data}.');
        final data = result.data;

        // Check if the response indicates the mobile number is available
        if (data is Map<String, dynamic> &&
            data.containsKey('status') &&
            data['status'] == 200 &&
            data.containsKey('data') &&
            data['data'] is Map<String, dynamic> &&
            data['data'].containsKey('available') &&
            data['data']['available'] == true) {
          return right(true);
        }

        // If mobile number is already in use
        if (data is Map<String, dynamic> &&
            data.containsKey('status') &&
            data['status'] == 409) {
          return left(
            NetworkFailure(
              message:
                  data.containsKey('message')
                      ? data['message'].toString()
                      : 'Mobile number already in use',
              statusCode: 409,
              type: NetworkErrorType.conflict,
            ),
          );
        }

        // For any other response
        return left(
          NetworkFailure(
            message:
                data is Map<String, dynamic> && data.containsKey('message')
                    ? data['message'].toString()
                    : 'Failed to verify mobile number',
          ),
        );
      });
    } catch (e) {
      dev.log('MERCHANT-AUTH-REPOSITORY-IMPL-VERIFY-MOBILE-ERROR: $e');
      return left(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<NetworkFailure, bool>> changePassword(
    PostMerchantChangePassword request,
  ) async {
    final config = RequestConfig(
      baseUrl: ApiConfig.baseUrl,
      endpoint: ApiConfig.merchantChangePassword,
      method: RequestMethod.post,
      body: jsonEncode(request.toJson()),
    );

    try {
      final response = await _apiService.request(
        config: config,
        responseConverter: (data) => data,
      );

      return response.fold((failure) => left(failure), (result) {
        final data = result.data;

        if (data is Map<String, dynamic> &&
            data.containsKey('status') &&
            data['status'] == 200) {
          return right(true);
        }

        return left(
          NetworkFailure(
            message:
                data is Map<String, dynamic> && data.containsKey('message')
                    ? data['message'].toString()
                    : 'Failed to change password',
          ),
        );
      });
    } catch (e) {
      dev.log('MERCHANT-AUTH-REPOSITORY-IMPL-CHANGE-PASSWORD-ERROR: $e');
      return left(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<NetworkFailure, bool>> forgotPassword(
    PostMerchantForgotPassword request,
  ) async {
    final config = RequestConfig(
      baseUrl: ApiConfig.baseUrl,
      endpoint: ApiConfig.merchantForgotPassword,
      method: RequestMethod.post,
      body: jsonEncode(request.toJson()),
    );

    try {
      final response = await _apiService.request(
        config: config,
        responseConverter: (data) => data,
      );

      return response.fold((failure) => left(failure), (result) {
        final data = result.data;

        if (data is Map<String, dynamic> &&
            data.containsKey('status') &&
            (data['status'] == 200 || data['status'] == 201)) {
          return right(true);
        }

        return left(
          NetworkFailure(
            message:
                data is Map<String, dynamic> && data.containsKey('message')
                    ? data['message'].toString()
                    : 'Failed to process forgot password request',
          ),
        );
      });
    } catch (e) {
      dev.log('MERCHANT-AUTH-REPOSITORY-IMPL-FORGOT-PASSWORD-ERROR: $e');
      return left(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, bool>> logout(String merchantId) async {
    final config = RequestConfig(
      baseUrl: ApiConfig.baseUrl,
      endpoint: ApiConfig.merchantLogout,
      method: RequestMethod.post,
      body: jsonEncode({'merchant_id': merchantId}),
    );

    try {
      final response = await _apiService.request(
        config: config,
        responseConverter: (data) => data,
      );

      return response.fold(
        (failure) => left(AuthFailure(message: failure.message)),
        (result) {
          final data = result.data;

          if (data is Map<String, dynamic> &&
              data.containsKey('status') &&
              data['status'] == 200) {
            return right(true);
          }

          return left(
            AuthFailure(
              message:
                  data is Map<String, dynamic> && data.containsKey('message')
                      ? data['message'].toString()
                      : 'Failed to logout',
            ),
          );
        },
      );
    } catch (e) {
      dev.log('MERCHANT-AUTH-REPOSITORY-IMPL-LOGOUT-ERROR: $e');
      return left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<NetworkFailure, bool>> resetPassword(
    PostMerchantResetPassword request,
  ) async {
    final config = RequestConfig(
      baseUrl: ApiConfig.baseUrl,
      endpoint: ApiConfig.merchantResetPassword,
      method: RequestMethod.post,
      body: jsonEncode(request.toJson()),
    );

    try {
      final response = await _apiService.request(
        config: config,
        responseConverter: (data) => data,
      );

      return response.fold((failure) => left(failure), (result) {
        final data = result.data;

        if (data is Map<String, dynamic> &&
            data.containsKey('status') &&
            data['status'] == 200) {
          return right(true);
        }

        return left(
          NetworkFailure(
            message:
                data is Map<String, dynamic> && data.containsKey('message')
                    ? data['message'].toString()
                    : 'Failed to reset password',
          ),
        );
      });
    } catch (e) {
      dev.log('MERCHANT-AUTH-REPOSITORY-IMPL-RESET-PASSWORD-ERROR: $e');
      return left(NetworkFailure(message: e.toString()));
    }
  }
}
