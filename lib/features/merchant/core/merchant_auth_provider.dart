import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
 import 'package:pack/pack.dart';
import 'dart:developer' as dev;
import 'package:pack/services/failure/failure.dart';

 import '../../../core/data/model/model.dart';
 import '../../../core/services/merchant_auth_service.dart';
import '../../../utils/handler/notification_service_handler.dart';

class MerchantAuthProvider with ChangeNotifier {
  final MerchantAuthService _authService;

  MerchantAuthProvider(this._authService) {
    // Listen to authentication status stream
    _initialize();
    _authService.authStatusStream.listen((status) {
      _authStatus = status;
      notifyListeners();
    });
  }

  Future<void> initialize() async => await _initialize();

  Future<void> _initialize() async {
    await _authService.initialize().then((merchant) {
      if (merchant != null) {
        _currentMerchant = merchant.merchant;
        _currentSubscription = merchant.subscription;
        _authStatus = AuthStatus.authenticated;
      } else {
        _authStatus = AuthStatus.uninitialized;
      }
      notifyListeners();
    });
  }

  AuthStatus _authStatus = AuthStatus.uninitialized;
  AuthStatus get authStatus => _authStatus;

  MerchantModel? _currentMerchant;
  MerchantModel? get currentMerchant => _currentMerchant;

  MerchantSubscriptionModel? _currentSubscription;
  MerchantSubscriptionModel? get currentSubscription => _currentSubscription;

  // Registration
  Future<Either<NetworkFailure, bool>> registerMerchant(
    MerchantRegistrationPayload merchant,
  ) async {
    final result = await _authService.registerMerchant(merchant);

    return result.fold((failure) => Left(failure), (success) {
      NotificationService.showOTPNotification("123456"); // Show demo OTP
      // If registration is successful, update auth status
      _authStatus = AuthStatus.otpRequired;
      notifyListeners();
      return Right(true);
    });
  }

  // Login
  Future<Either<NetworkFailure, MerchantLoginResponse>> login({
    required PostMerchantLogin request,
  }) async {
    final result = await _authService.login(request: request);

    return result.fold((failure) => Left(failure), (merchant) {
      if (merchant.type == MerchantLoginResponseType.otpRequired) {
        _authStatus = AuthStatus.otpRequired;
        notifyListeners();
        return Right(merchant);
      }
      _currentMerchant = merchant.merchant!.merchant;
      _currentSubscription = merchant.merchant!.subscription;
      _authStatus = AuthStatus.authenticated;

      notifyListeners();
      return Right(merchant);
    });
  }

  // OTP Verification
  Future<Either<NetworkFailure, MerchantOtpVerificationResponse>> verifyOTP(
    PostMerchantOtpVerification request,
  ) async {
    final result = await _authService.verifyOTP(request: request);

    return result.fold((failure) => Left(failure), (success) {
      if (success.status == 200) {
        _authStatus = AuthStatus.authenticated;
        notifyListeners();
      }
      return Right(success);
    });
  }

  // Resend OTP
  Future<Either<NetworkFailure, bool>> resendOTP(String email) async {
    return await _authService.resendOTP(email);
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _currentMerchant = null;
  }

  // Dispose method
  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }
}
