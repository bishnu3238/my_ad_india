import 'dart:developer' as dev;

import 'package:equatable/equatable.dart';
import 'package:pack/pack.dart';
import '../merchant/merchant.dart';
import '../merchant/merchant_service_details_model.dart';

enum OtpVerificationResponseType {
  success,
  alreadyVerified,
  invalidOtp,
  notFound,
  error,
}

class MerchantOtpVerificationResponse extends Equatable {
  final OtpVerificationResponseType type;
  final int status;
  final String message;
  final Map<String, dynamic>? data;
  final String timestamp;
  final String? merchantId;
  final MerchantData? merchant; // Nullable, only used in success case

  const MerchantOtpVerificationResponse._({
    required this.type,
    required this.status,
    required this.message,
    this.data,
    required this.timestamp,
    this.merchantId,
    this.merchant,
  });

  // Factory for success response
  factory MerchantOtpVerificationResponse.success({
    required int status,
    required String message,
    required Map<String, dynamic> data,
    required MerchantData merchantData,
    required String timestamp,
  }) {
    return MerchantOtpVerificationResponse._(
      type: OtpVerificationResponseType.success,
      status: status,
      message: message,
      data: data,
      merchant: merchantData,
      timestamp: timestamp,
      merchantId: data['merchant_id']?.toString(),
    );
  }

  // Factory for already verified response
  factory MerchantOtpVerificationResponse.alreadyVerified({
    required int status,
    required String message,
    Map<String, dynamic>? data,
    required String timestamp,
  }) {
    return MerchantOtpVerificationResponse._(
      type: OtpVerificationResponseType.alreadyVerified,
      status: status,
      message: message,
      data: data,
      merchant: null,
      timestamp: timestamp,
    );
  }

  // Factory for invalid OTP response
  factory MerchantOtpVerificationResponse.invalidOtp({
    required int status,
    required String message,
    Map<String, dynamic>? data,
    required String timestamp,
  }) {
    return MerchantOtpVerificationResponse._(
      type: OtpVerificationResponseType.invalidOtp,
      status: status,
      message: message,
      data: data,
      timestamp: timestamp,
    );
  }

  // Factory for merchant not found response
  factory MerchantOtpVerificationResponse.notFound({
    required int status,
    required String message,
    Map<String, dynamic>? data,
    required String timestamp,
  }) {
    return MerchantOtpVerificationResponse._(
      type: OtpVerificationResponseType.notFound,
      status: status,
      message: message,
      data: data,
      timestamp: timestamp,
    );
  }

  // Factory for general error response
  factory MerchantOtpVerificationResponse.error({
    required int status,
    required String message,
    Map<String, dynamic>? data,
    required String timestamp,
  }) {
    return MerchantOtpVerificationResponse._(
      type: OtpVerificationResponseType.error,
      status: status,
      message: message,
      data: data,
      timestamp: timestamp,
    );
  }

  // Factory constructor to parse JSON
  factory MerchantOtpVerificationResponse.fromJson(Map<String, dynamic> json) {
    dev.log('JSON: $json');
    final status = json.getInt('status');
    final message = json.getString('message');
    final data = json['data'] != null ? Map<String, dynamic>.from(json['data']) : null;
    final timestamp = json.containsKey('timestamp')
        ? json.getString('timestamp')
        : DateTime.now().toIso8601String();

    // Determine the response type based on status code and data
    if (status == 200 && data != null && data.containsKey('merchant') && data.containsKey('subscription') && data.containsKey('service_details')) {
      return MerchantOtpVerificationResponse.success(
        status: status,
        message: message,
        merchantData: MerchantData(
          merchant: MerchantModel.fromJson(data['merchant']),
          subscription: MerchantSubscriptionModel.fromJson(data['subscription']),
          serviceDetails: MerchantServiceDetailsModel.fromJson(data['service_details'] ?? {}),
        ),
        data: data,
        timestamp: timestamp,
      );
    } else if (status == 200 && data != null && data['status'] == 'already_verified') {
      return MerchantOtpVerificationResponse.alreadyVerified(
        status: status,
        message: message,
        data: data,
        timestamp: timestamp,
      );
    } else if (status == 400 && data != null && data['status'] == 'invalid_otp') {
      return MerchantOtpVerificationResponse.invalidOtp(
        status: status,
        message: message,
        data: data,
        timestamp: timestamp,
      );
    } else if (status == 404 && data != null && data['status'] == 'not_found') {
      return MerchantOtpVerificationResponse.notFound(
        status: status,
        message: message,
        data: data,
        timestamp: timestamp,
      );
    } else {
      return MerchantOtpVerificationResponse.error(
        status: status,
        message: message,
        data: data,
        timestamp: timestamp,
      );
    }
  }

  // Helper method to check type and handle accordingly with pattern matching
  T when<T>({
    required T Function(int status, String message, String? merchantId, MerchantData merchant, String timestamp) success,
    required T Function(int status, String message, String timestamp) alreadyVerified,
    required T Function(int status, String message, String timestamp) invalidOtp,
    required T Function(int status, String message, String timestamp) notFound,
    required T Function(int status, String message, Map<String, dynamic>? data, String timestamp) error,
  }) {
    switch (type) {
      case OtpVerificationResponseType.success:
        return success(status, message, merchantId, merchant!, timestamp);
      case OtpVerificationResponseType.alreadyVerified:
        return alreadyVerified(status, message, timestamp);
      case OtpVerificationResponseType.invalidOtp:
        return invalidOtp(status, message, timestamp);
      case OtpVerificationResponseType.notFound:
        return notFound(status, message, timestamp);
      case OtpVerificationResponseType.error:
        return error(status, message, data, timestamp);
    }
  }

  // Helper method to handle the response with more concise callbacks
  T fold<T>({
    required T Function(String? merchantId, MerchantData merchant) onSuccess,
    T Function()? onAlreadyVerified,
    T Function()? onInvalidOtp,
    T Function()? onNotFound,
    required T Function(String message) onError,
  }) {
    switch (type) {
      case OtpVerificationResponseType.success:
        return onSuccess(merchantId, merchant!);
      case OtpVerificationResponseType.alreadyVerified:
        return onAlreadyVerified?.call() ?? onError(message);
      case OtpVerificationResponseType.invalidOtp:
        return onInvalidOtp?.call() ?? onError(message);
      case OtpVerificationResponseType.notFound:
        return onNotFound?.call() ?? onError(message);
      case OtpVerificationResponseType.error:
        return onError(message);
    }
  }

  @override
  String toString() {
    return 'MerchantOtpVerificationResponse{type: $type, status: $status, message: $message, merchantId: $merchantId, merchant: $merchant, timestamp: $timestamp}';
  }

  @override
  List<Object?> get props => [type, status, message, merchantId, merchant];
}