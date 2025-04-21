// lib/core/model/referral_response.dart

import 'dart:developer' as dev;

enum ReferralResponseType { success, error }

class ReferralResponse {
  final ReferralResponseType type;
  final int status;
  final String message;
  final Map<String, dynamic>? data; // Optional data for error details
  final String timestamp;

  ReferralResponse._({
    required this.type,
    required this.status,
    required this.message,
    this.data,
    required this.timestamp,
  });

  // Factory for success response
  factory ReferralResponse.success({
    required int status,
    required String message,
    required String timestamp,
  }) {
    return ReferralResponse._(
      type: ReferralResponseType.success,
      status: status,
      message: message,
      timestamp: timestamp,
    );
  }

  // Factory for error response
  factory ReferralResponse.error({
    required int status,
    required String message,
    Map<String, dynamic>? data,
    required String timestamp,
  }) {
    return ReferralResponse._(
      type: ReferralResponseType.error,
      status: status,
      message: message,
      data: data,
      timestamp: timestamp,
    );
  }

  // Factory constructor to parse JSON
  factory ReferralResponse.fromJson(Map<String, dynamic> json) {
    dev.log('Referral Response Received JSON: $json');
    final status = json['status'] as int;
    final message = json['message'] as String;
    final data = json['data'] as Map<String, dynamic>?;
    final timestamp = json['timestamp'] as String;

    if (status == 200) {
      return ReferralResponse.success(
        status: status,
        message: message,
        timestamp: timestamp,
      );
    } else {
      return ReferralResponse.error(
        status: status,
        message: message,
        data: data,
        timestamp: timestamp,
      );
    }
  }

  // Helper method to check type and cast accordingly
  T when<T>({
    required T Function(int status, String message, String timestamp) success,
    required T Function(
      int status,
      String message,
      Map<String, dynamic>? data,
      String timestamp,
    )
    error,
  }) {
    switch (type) {
      case ReferralResponseType.success:
        return success(status, message, timestamp);
      case ReferralResponseType.error:
        return error(status, message, data, timestamp);
    }
  }

  @override
  String toString() {
    return 'ReferralResponse{type: $type, status: $status, message: $message, data: $data, timestamp: $timestamp}';
  }
}
