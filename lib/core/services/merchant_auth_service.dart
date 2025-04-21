import 'dart:async';
import 'dart:developer' as dev;
import 'package:dartz/dartz.dart';
import 'package:my_ad/core/domain/data_store/data_store.dart';
import 'package:pack/pack.dart';
import 'package:pack/services/failure/failure.dart';

import '../../utils/handler/notification_service_handler.dart';
import '../data/model/model.dart';
import '../domain/repository/merchant_auth_repository.dart';

// Authentication States

class MerchantAuthService {
  final MerchantDashboardStore _store;
  final MerchantAuthRepository _repository;

  MerchantAuthService(this._store, this._repository) {
    initialize();
  }

  Future<MerchantData?> initialize() async {
    dev.log("INITIALIZE");
    await _store.loadFromLocalStorage(MerchantDashboardModel.fromLocalMap);
    dev.log(
      "QUESTION: IS MERCHANT IS AUTHENTICATED?: ${_store.entity!.isAuthenticated}",
    );
    if (_store.entity!.isAuthenticated) {
      dev.log("ANS: MERCHANT IS ALREADY AUTHENTICATED");
      _authStatusController.add(AuthStatus.authenticated);

      /// TODO: [FetchLatestData] ------------------------------------------
      // await _repository.fetchLatestData();
    }

    dev.log("initialize end");
    return null;
  }

  // Stream controller for authentication status
  final _authStatusController = StreamController<AuthStatus>.broadcast();
  Stream<AuthStatus> get authStatusStream => _authStatusController.stream;

  // Registration method
  Future<Either<NetworkFailure, MerchantRegistrationResponse>> registerMerchant(
    PostMerchantRegistration merchant,
  ) async {
    try {
      final requestBody = merchant;
      var result = await _repository.registration(requestBody);
      return result.fold((failure) => left(failure), (data) {
        data.fold(
          onSuccess: (merchant, subscription) {
            _store.saveToLocalStorage();
            _authStatusController.add(AuthStatus.authenticated);
          },
          onError: (t) {
            dev.log('Registration failed: $t');
            return Left(NetworkFailure(message: t));
          },
          onConflict: () {
            dev.log('Email or username already exists.');
            return Left(
              NetworkFailure(message: 'Email or username already exists.'),
            );
          },
          onInvalidInput: (errors) {
            dev.log('Invalid input: $errors');
            return Left(NetworkFailure(message: 'Invalid input'));
          },
          onOtpRequired: (data, otp, merchant) {
            dev.log(
              'Welcome ${merchant!.username} your otp is sent to register no ${merchant.mobile},Your Verification Code is $otp',
            );
          },
        );
        return right(data);
      });
    } catch (e) {
      return Left(NetworkFailure(message: e.toString()));
    }
  }

  // Login method
  Future<Either<NetworkFailure, MerchantLoginResponse>> login({
    required PostMerchantLogin request,
  }) async {
    try {
      final response = await _repository.login(request);
      return response.fold((failure) => Left(failure), (merchant) {
        _store.setEntity(MerchantDashboardModel.formLogin(merchant));

        if (merchant.type == MerchantLoginResponseType.otpRequired) {
          _authStatusController.add(AuthStatus.otpRequired);
          NotificationService.showOTPNotification(
            merchant.data!['otp'],
          ); // Use OTP from response
          return Right(merchant);
        }
        if (merchant.type == MerchantLoginResponseType.success) {
          _store.saveToLocalStorage();
          _authStatusController.add(AuthStatus.authenticated);
          return Right(merchant);
        }
        return Right(merchant);
      });
    } catch (e) {
      return Left(NetworkFailure(message: e.toString()));
    }
  }

  Future<Either<NetworkFailure, MerchantOtpVerificationResponse>> verifyOTP({
    required PostMerchantOtpVerification request,
  }) async {
    try {
      return await _repository
          .verifyOTP(request)
          .then(
            (value) => value.fold((failure) => left(failure), (result) {
              if (result.status == 200) {
                _store.setEntity(MerchantDashboardModel.formOtp(result));

                _authStatusController.add(AuthStatus.authenticated);
                return right(result);
              } else {
                return left(NetworkFailure(message: 'Invalid OTP'));
              }
            }),
          );
    } catch (e) {
      return Left(NetworkFailure(message: e.toString()));
    }
  }

  // Resend OTP
  Future<Either<NetworkFailure, bool>> resendOTP(String email) async {
    try {
      // TODO: Implement OTP resend API call
      // For now, this is a placeholder
      throw UnimplementedError('Resend OTP method not implemented');
    } catch (e) {
      return Left(NetworkFailure(message: e.toString()));
    }
  }

  // Logout method
  Future<void> logout() async {
    _store.updateEntity(
      (transform) => transform!.copyWith(
        isAuthenticated: false,
        merchant: MerchantData.empty(),
        services: [],
        planAccess: MerchantPlanAccessModel.empty(),
        serviceRequest: ServiceRequestModel.empty(),
        token: '',
        tokenExpiry: DateTime.timestamp(),
      ),
    );
    _store.clearLocalStorage();

    _authStatusController.add(AuthStatus.unauthenticated);
  }

  Future<Either<Failure, bool>> verifyPhoneNo(String mobile) async {
    return await _repository.verifyMobileNumber(mobile);
  }

  // Dispose method to close stream controller
  void dispose() {
    _authStatusController.close();
  }
}
