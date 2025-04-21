// models/merchant_service_response.dart
import 'dart:developer' as dev;

import 'package:equatable/equatable.dart';
import 'package:pack/pack.dart';
import '../merchant/merchant_service_model.dart';

class MerchantServiceResponse extends Equatable {
  final List<MerchantServiceModel> services;
  final bool success;
  final String message;
  final String timestamp;

  const MerchantServiceResponse({
    required this.services,
    this.success = false,
    this.message = '',
    this.timestamp = '',
  });

  factory MerchantServiceResponse.fromJson(Map<String, dynamic> json) {
    dev.log(' Fetch-Merchant-Service-Response.fromJson: $json');
    return MerchantServiceResponse(
      services:
          (json['data']['services'] as List<dynamic>)
              .map(
                (service) => MerchantServiceModel.fromJson(
                  service as Map<String, dynamic>,
                ),
              )
              .toList(),
      success: json.getBool('success'),
      timestamp: json.getString('timestamp'),
      message: json.getString('message'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'services': services.map((service) => service.toJson()).toList(),
      'success': success,
      'message': message,
      'timestamp': timestamp,
    };
  }

  @override
  List<Object?> get props => [services, success, message, timestamp];
}
