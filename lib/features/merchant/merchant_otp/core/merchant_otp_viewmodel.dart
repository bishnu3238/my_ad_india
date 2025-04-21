import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_ad/features/merchant/core/merchant_navigation.dart';
import 'package:pack/services/failure/failure.dart';
import 'package:pack/services/snack_bar_service/notify_service.dart';
import '../../../../core/data/model/model.dart';
import '../../../../core/data/model/response/merchant_otp_response.dart';
import '../../../../core/services/merchant_auth_service.dart';
import '../../merchant_dashboard/core/merchant_dashboard_route.dart';

class OTPProvider with ChangeNotifier {
  final String merchantId;
  final MerchantAuthService _authService;

  // Constants
  static const int maxOtpAttempts = 3;
  static const int otpResendCooldownSeconds = 30;
  static const int otpLength = 6;
  
  // State variables
  String _otp = '';
  bool _isLoading = false;
  int _otpAttempts = 0;
  DateTime? _lastResendTime;
  String? _errorMessage;
  Timer? _resendTimer;
  int _remainingResendTime = 0;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get otpAttempts => _otpAttempts;
  DateTime? get lastResendTime => _lastResendTime;
  int get remainingResendTime => _remainingResendTime;
  bool get hasReachedMaxAttempts => _otpAttempts >= maxOtpAttempts;

  bool get canResendOtp {
    if (_lastResendTime == null) return true;
    return _remainingResendTime <= 0;
  }

  OTPProvider(this._authService, {required this.merchantId}) {
    // Initialize the resend timer if there was a previous resend
    if (_lastResendTime != null) {
      _updateResendTimer();
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _updateResendTimer() {
    _resendTimer?.cancel();
    
    if (_lastResendTime == null) {
      _remainingResendTime = 0;
      return;
    }

    final elapsedSeconds = DateTime.now().difference(_lastResendTime!).inSeconds;
    _remainingResendTime = elapsedSeconds >= otpResendCooldownSeconds 
        ? 0 
        : otpResendCooldownSeconds - elapsedSeconds;

    if (_remainingResendTime > 0) {
      _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _remainingResendTime--;
        if (_remainingResendTime <= 0) {
          timer.cancel();
        }
        notifyListeners();
      });
    }
  }

  void setOtp(String otp) {
    _otp = otp;
    _errorMessage = null; // Clear error when user inputs new OTP
    notifyListeners();
  }

  void clearOtp() {
    _otp = '';
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> otpVerification(BuildContext context) async {
    // Validate OTP
    if (_otp.length != otpLength) {
      NotifyService.snackbar(
        context: context,
        message: 'Please enter the complete $otpLength-digit OTP',
        type: NotificationType.warning,
      );
      return;
    }

    // Check for max attempts
    if (hasReachedMaxAttempts) {
      _errorMessage = 'Maximum attempts reached. Please request a new OTP';
      notifyListeners();
      return;
    }

    _setLoading(true);
    _otpAttempts++;

    try {
      final request = PostMerchantOtpVerification(merchantId: merchantId, otp: _otp);
      final result = await _authService.verifyOTP(request: request);

      result.fold(
        (failure) => _handleFailure(failure, context),
        (response) => _handleOtpResponse(response, context),
      );
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      dev.log('OTP_VERIFICATION_UNEXPECTED_ERROR: $e');
      NotifyService.snackbar(
        context: context,
        message: 'Verification failed. Please try again',
        type: NotificationType.error,
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resendOTP(BuildContext context) async {
    if (!canResendOtp) {
      NotifyService.snackbar(
        context: context,
        message: 'Please wait $_remainingResendTime seconds before requesting another OTP',
        type: NotificationType.warning,
      );
      return;
    }

    _setLoading(true);
    _lastResendTime = DateTime.now();
    _updateResendTimer();
    _otpAttempts = 0; // Reset attempts when new OTP is requested
    
    try {
      final result = await _authService.resendOTP(merchantId);

      result.fold(
        (failure) => _handleFailure(failure, context), 
        (success) {
          if (success) {
            _errorMessage = null;
            clearOtp(); // Clear previous OTP input
            dev.log('OTP_RESENT_SUCCESS: { merchant_id: $merchantId }');
            NotifyService.snackbar(
              context: context,
              message: 'OTP resent successfully. Please check your phone',
              type: NotificationType.success,
            );
          } else {
            _errorMessage = 'Failed to resend OTP. Please try again';
            NotifyService.snackbar(
              context: context,
              message: 'Failed to resend OTP',
              type: NotificationType.error,
            );
          }
        }
      );
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      dev.log('OTP_RESEND_UNEXPECTED_ERROR: $e');
      NotifyService.snackbar(
        context: context,
        message: 'Failed to resend OTP. Please try again',
        type: NotificationType.error,
      );
    } finally {
      _setLoading(false);
    }
  }

  void _handleOtpResponse(
    MerchantOtpVerificationResponse response,
    BuildContext context,
  ) {
    response.fold(
      onSuccess: (merchantId) {
        _errorMessage = null;
        NotifyService.snackbar(
          context: context,
          message: 'OTP verification successful',
          type: NotificationType.success,
        );
        
        // Navigate to dashboard with slight delay to show success message
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            context.go(MerchantDashboardRoute.dashboard);
          }
        });
        return true;
      },
      onAlreadyVerified: () {
        // If already verified, we can just proceed to dashboard
        dev.log(
          "OTP_ALREADY_VERIFIED: {merchant_id: $merchantId, ${response.data!},}",
        );
        _errorMessage = null;
        NotifyService.snackbar(
          context: context,
          message: 'Account already verified',
          type: NotificationType.success,
        );
        
        // Navigate to dashboard with slight delay to show success message
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            context.go(MerchantDashboardRoute.dashboard);
          }
        });
        return true;
      },
      onInvalidOtp: () {
        _errorMessage = 'Invalid OTP. Please check and try again';
        dev.log("OTP_INVALID: {merchant_id: $merchantId, attempts: $_otpAttempts}");
        
        // Check if max attempts reached
        if (hasReachedMaxAttempts) {
          _errorMessage = 'Maximum attempts reached. Please request a new OTP';
        }
        
        notifyListeners();
        return true;
      },
      onNotFound: () {
        _errorMessage = 'Merchant account not found or inactive';
        dev.log("OTP_MERCHANT_NOT_FOUND: {merchant_id: $merchantId}");
        notifyListeners();
        return true;
      },
      onError: (message) {
        _errorMessage = message;
        dev.log("OTP_VERIFICATION_ERROR: {merchant_id: $merchantId, error: $message}");
        notifyListeners();
        return true;
      },
    );
  }

  void _handleFailure(NetworkFailure failure, BuildContext context) {
    _errorMessage = failure.message;

    dev.log(
      'OTP_VERIFICATION_NETWORK_FAILURE: {merchant_id: $merchantId, error_code: ${failure.statusCode}, error_message: ${failure.message}}',
    );
    
    // Handle specific error types
    if (failure.type == NetworkErrorType.timeout) {
      _errorMessage = 'Connection timed out. Please check your internet and try again';
    } else if (failure.type == NetworkErrorType.noInternet) {
      _errorMessage = 'No internet connection. Please check your connection and try again';
    }
    
    NotifyService.snackbar(
      context: context,
      message: _errorMessage ?? 'Verification failed',
      type: NotificationType.error,
    );

    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
