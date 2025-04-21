import 'package:dartz/dartz.dart';
import 'package:my_ad/core/data/model/model.dart';
import 'package:pack/services/service.dart';

import '../../data/model/response/merchant_otp_response.dart';

abstract class MerchantAuthRepository {
  /// Merchant Registration
  Future<Either<NetworkFailure, MerchantRegistrationResponse>> registration(
    PostMerchantRegistration request,
  );

  /// Merchant Login
  Future<Either<NetworkFailure, MerchantLoginResponse>> login(
    PostMerchantLogin request,
  );

  /// Merchant OTP verification
  Future<Either<NetworkFailure, MerchantOtpVerificationResponse>> verifyOTP(
    PostMerchantOtpVerification request,
  );

  /// Merchant resend OTP
  Future<Either<NetworkFailure, bool>> resendOTP(String merchantId);

  /// Verify mobile number availability
  Future<Either<NetworkFailure, bool>> verifyMobileNumber(String mobile);

  /// Merchant logout
  Future<Either<AuthFailure, bool>> logout(String merchantId);

  /// Merchant forgot password
  Future<Either<NetworkFailure, bool>> forgotPassword(
    PostMerchantForgotPassword request,
  );

  /// Merchant reset password
  Future<Either<NetworkFailure, bool>> resetPassword(
    PostMerchantResetPassword request,
  );
  
  /// Merchant change password
  Future<Either<NetworkFailure, bool>> changePassword(
    PostMerchantChangePassword request,
  );
}
