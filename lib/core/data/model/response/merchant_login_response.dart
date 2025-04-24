import 'dart:developer' as dev;

import 'package:pack/pack.dart';
import '../merchant/merchant.dart';
import '../merchant/merchant_service_details_model.dart';

enum MerchantLoginResponseType { success, otpRequired, error }

class MerchantLoginResponse {
  final MerchantLoginResponseType type;
  final int status;
  final String message;
  final Map<String, dynamic>?
  data; // Nullable for error case; contains merchant_id and otp for otpRequired
  final String timestamp;
  final MerchantData? merchant; // Nullable, only used in success case

  MerchantLoginResponse._({
    required this.type,
    required this.status,
    required this.message,
    this.data,
    required this.timestamp,
    this.merchant,
  });

  // Factory for success response
  factory MerchantLoginResponse.success({
    required int status,
    required String message,
    required MerchantData data,
    required String timestamp,
  }) {
    return MerchantLoginResponse._(
      type: MerchantLoginResponseType.success,
      status: status,
      message: message,
      merchant: data,
      timestamp: timestamp,
    );
  }

  // Factory for OTP required response
  factory MerchantLoginResponse.otpRequired({
    required int status,
    required String message,
    required Map<String, dynamic> data, // Contains merchant_id and otp
    required String timestamp,
  }) {
    return MerchantLoginResponse._(
      type: MerchantLoginResponseType.otpRequired,
      status: status,
      message: message,
      data: data,
      timestamp: timestamp,
    );
  }

  // Factory for error response
  factory MerchantLoginResponse.error({
    required int status,
    required String message,
    Map<String, dynamic>? data,
    required String timestamp,
  }) {
    return MerchantLoginResponse._(
      type: MerchantLoginResponseType.error,
      status: status,
      message: message,
      data: data,
      timestamp: timestamp,
    );
  }

  // Factory constructor to parse JSON
  factory MerchantLoginResponse.fromJson(Map<String, dynamic> json) {
    dev.log('JSON: $json');
    final status = json.getInt('status');
    final message = json.getString('message');
    final data =
        json['data'] != null ? Map<String, dynamic>.from(json['data']) : null;
    final timestamp = json.getString('timestamp');

    if (status == 200 &&
        data != null &&
        data.containsKey('merchant') &&
        data.containsKey('subscription') &&
        data.containsKey('service_details')) {
      return MerchantLoginResponse.success(
        status: status,
        message: message,
        data: MerchantData(
          merchant: MerchantModel.fromJson(data['merchant']),
          subscription: MerchantSubscriptionModel.fromJson(
            data['subscription'],
          ),
          serviceDetails: MerchantServiceDetailsModel.fromJson(
            data['service_details'] ?? {},
          ),
        ),
        timestamp: timestamp,
      );
    } else if (status == 201 &&
        data != null &&
        data.containsKey('merchant_id') &&
        data.containsKey('otp')) {
      return MerchantLoginResponse.otpRequired(
        status: status,
        message: message,
        data: data,
        timestamp: timestamp,
      );
    } else {
      return MerchantLoginResponse.error(
        status: status,
        message: message,
        data: data,
        timestamp: timestamp,
      );
    }
  }

  // Helper method to check type and cast accordingly
  T when<T>({
    required T Function(
      int status,
      String message,
      MerchantData data,
      String timestamp,
    )
    success,
    required T Function(
      int status,
      String message,
      Map<String, dynamic> data,
      String timestamp,
    )
    otpRequired,
    required T Function(
      int status,
      String message,
      Map<String, dynamic>? data,
      String timestamp,
    )
    error,
  }) {
    switch (type) {
      case MerchantLoginResponseType.success:
        return success(status, message, merchant!, timestamp);
      case MerchantLoginResponseType.otpRequired:
        return otpRequired(status, message, data!, timestamp);
      case MerchantLoginResponseType.error:
        return error(status, message, data, timestamp);
    }
  }

  @override
  String toString() {
    return 'MerchantLoginResponse{type: $type, status: $status, message: $message, data: $data, timestamp: $timestamp, merchant: $merchant}';
  }
}
