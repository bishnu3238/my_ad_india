import 'package:equatable/equatable.dart';

class ServiceRequestResponse extends Equatable {
  final bool success;
  final int? requestId;
  final String message;
  final String timestamp;

  const ServiceRequestResponse({
    required this.success,
    this.requestId,
    required this.message,
    required this.timestamp,
  });

  factory ServiceRequestResponse.fromJson(Map<String, dynamic> json) {
    return ServiceRequestResponse(
      success: json['success'] ?? false,
      requestId: json['data'] != null ? json['data']['request_id'] : null,
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }

  @override
  List<Object?> get props => [success, requestId, message, timestamp];
}