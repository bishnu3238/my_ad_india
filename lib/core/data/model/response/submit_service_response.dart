
import 'package:pack/pack.dart';

import '../merchant/merchant_service_model.dart';

class SubmitServiceResponse {
  final bool success;
  final String message;
  final MerchantServiceModel? service; // Null for delete operations
  final String? serviceId; // Used for delete operations

  const SubmitServiceResponse({
    required this.success,
    required this.message,
    this.service,
    this.serviceId,
  });

  factory SubmitServiceResponse.fromJson(Map<String, dynamic> json) {
    return SubmitServiceResponse(
      success: json.getBool('success'),
      message: json.getString('message'),
      service: json['data']?['service'] != null
          ? MerchantServiceModel.fromJson(json['data']['service'])
          : null,
      serviceId: json['data']?['service_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': {
        if (service != null) 'service': service!.toJson(),
        if (serviceId != null) 'service_id': serviceId,
      },
    };
  }
}