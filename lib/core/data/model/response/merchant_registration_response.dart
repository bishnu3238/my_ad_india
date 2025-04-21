// lib/core/data/model/response/merchant_registration_response.dart
import 'dart:developer' as dev;

import 'package:pack/pack.dart';
import '../model.dart';

enum MerchantRegistrationStatus {
  success,
  error,
  conflict,
  invalidInput,
  otpRequired,
}

class MerchantRegistrationResponse {
  final MerchantRegistrationStatus status;
  final int statusCode;
  final String message;
  final MerchantModel? merchant;
  final MerchantSubscriptionModel? subscription;
  final String timestamp;
  final Map<String, dynamic>? errors;
  final Map<String, dynamic>? data; // Add data field for OTP case
  final String? otp; // Add explicit OTP field

  MerchantRegistrationResponse._({
    required this.status,
    required this.statusCode,
    required this.message,
    this.merchant,
    this.subscription,
    required this.timestamp,
    this.errors,
    this.data,
    this.otp,
  });

  factory MerchantRegistrationResponse.success({
    required int statusCode,
    required String message,
    required MerchantModel merchant,
    required MerchantSubscriptionModel subscription,
    required String timestamp,
  }) {
    return MerchantRegistrationResponse._(
      status: MerchantRegistrationStatus.success,
      statusCode: statusCode,
      message: message,
      merchant: merchant,
      subscription: subscription,
      timestamp: timestamp,
      errors: null,
      data: null,
      otp: null,
    );
  }

  factory MerchantRegistrationResponse.conflict({
    required int statusCode,
    required String message,
    required String timestamp,
  }) {
    return MerchantRegistrationResponse._(
      status: MerchantRegistrationStatus.conflict,
      statusCode: statusCode,
      message: message,
      merchant: null,
      subscription: null,
      timestamp: timestamp,
      errors: null,
      data: null,
      otp: null,
    );
  }

  factory MerchantRegistrationResponse.invalidInput({
    required int statusCode,
    required String message,
    required Map<String, dynamic> errors,
    required String timestamp,
  }) {
    return MerchantRegistrationResponse._(
      status: MerchantRegistrationStatus.invalidInput,
      statusCode: statusCode,
      message: message,
      merchant: null,
      subscription: null,
      timestamp: timestamp,
      errors: errors,
      data: null,
      otp: null,
    );
  }

  factory MerchantRegistrationResponse.error({
    required int statusCode,
    required String message,
    Map<String, dynamic>? errors,
    required String timestamp,
  }) {
    return MerchantRegistrationResponse._(
      status: MerchantRegistrationStatus.error,
      statusCode: statusCode,
      message: message,
      merchant: null,
      subscription: null,
      timestamp: timestamp,
      errors: errors,
      data: null,
      otp: null,
    );
  }

  factory MerchantRegistrationResponse.otpRequired({
    required int statusCode,
    required String message,
    required Map<String, dynamic> data,
    required String timestamp,
    String? otp,
  }) {
    return MerchantRegistrationResponse._(
      status: MerchantRegistrationStatus.otpRequired,
      statusCode: statusCode,
      message: message,
      merchant: data['merchant'] != null 
          ? MerchantModel.fromJson(data['merchant'] as Map<String, dynamic>) 
          : null,
      subscription: data['subscription'] != null 
          ? MerchantSubscriptionModel.fromJson(data['subscription'] as Map<String, dynamic>) 
          : null,
      timestamp: timestamp,
      errors: null,
      data: data,
      otp: otp ?? data['otp']?.toString(),
    );
  }

  factory MerchantRegistrationResponse.fromJson(Map<String, dynamic> json) {
    dev.log('MERCHANT REGISTRATION RESPONSE: $json');
    final statusCode = json.getInt('status');
    final message = json.getString('message');
    final timestamp = json.getString('timestamp');
    final data = json['data'] != null ? Map<String, dynamic>.from(json['data']) : null;
    
    // Extract OTP if available
    String? otp;
    if (data != null && data.containsKey('otp')) {
      otp = data['otp'].toString();
    }

    // Check if this is an OTP verification required response
    if (statusCode == 201 && data != null && 
        (message.toLowerCase().contains('otp') || 
         message.toLowerCase().contains('verify') || 
         data.containsKey('otp'))) {
      
      return MerchantRegistrationResponse.otpRequired(
        statusCode: statusCode,
        message: message,
        data: data,
        timestamp: timestamp,
        otp: otp,
      );
    } 
    // Handle successful registration with merchant and subscription data
    else if ((statusCode == 200 || statusCode == 201) && 
             data != null && 
             data.containsKey('merchant') && 
             data.containsKey('subscription')) {
      
      final merchantJson = data['merchant'] as Map<String, dynamic>;
      final subscriptionJson = data['subscription'] as Map<String, dynamic>;
      
      return MerchantRegistrationResponse.success(
        statusCode: statusCode,
        message: message,
        merchant: MerchantModel.fromJson(merchantJson),
        subscription: MerchantSubscriptionModel.fromJson(subscriptionJson),
        timestamp: timestamp,
      );
    } 
    // Handle conflict (duplicate email/username)
    else if (statusCode == 409) {
      return MerchantRegistrationResponse.conflict(
        statusCode: statusCode,
        message: message,
        timestamp: timestamp,
      );
    } 
    // Handle validation errors
    else if (statusCode == 400 && data != null) {
      Map<String, dynamic> errors = {};
      
      // Handle different error formats
      if (data is List) {
        errors = {'missing_fields': data};
      } else {
        errors = data;
      }

      
      return MerchantRegistrationResponse.invalidInput(
        statusCode: statusCode,
        message: message,
        errors: errors,
        timestamp: timestamp,
      );
    } 
    // Handle all other errors
    else {
      return MerchantRegistrationResponse.error(
        statusCode: statusCode,
        message: message,
        errors: data,
        timestamp: timestamp,
      );
    }
  }

  T fold<T>({
      T Function(MerchantModel merchant, MerchantSubscriptionModel subscription)? onSuccess,
    T Function()? onConflict,
    T Function(Map<String, dynamic> errors)? onInvalidInput,
    required T Function(String message) onError,
    T Function(Map<String, dynamic> data, String? otp, MerchantModel? merchant)? onOtpRequired,
  }) {
    switch (status) {
      case MerchantRegistrationStatus.success:
        return onSuccess?.call(merchant!, subscription!) ?? onError(message);
      case MerchantRegistrationStatus.conflict:
        return onConflict?.call() ?? onError(message);
      case MerchantRegistrationStatus.invalidInput:
        return onInvalidInput?.call(errors!) ?? onError(message);
      case MerchantRegistrationStatus.error:
        return onError(message);
      case MerchantRegistrationStatus.otpRequired:
        return onOtpRequired?.call(data!, otp, merchant) ?? onError(message);
    }
  }

  // Get merchant ID from response
  String? getMerchantId() {
    if (merchant != null) {
      return merchant!.id.toString();
    } else if (data != null) {
      if (data!.containsKey('merchant') && data!['merchant'] is Map<String, dynamic>) {
        return data!['merchant']['id']?.toString();
      } else if (data!.containsKey('merchant_id')) {
        return data!['merchant_id']?.toString();
      }
    }
    return null;
  }

  @override
  String toString() {
    return 'MerchantRegistrationResponse{status: $status, statusCode: $statusCode, message: $message, merchant: $merchant, subscription: $subscription, timestamp: $timestamp, errors: $errors, data: $data, otp: $otp}';
  }
}
