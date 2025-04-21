import 'package:equatable/equatable.dart';

class ServiceValidationResponse extends Equatable {
  final bool success;
  final bool isValid;
  final String message;
  final String timestamp;

  const ServiceValidationResponse({
    required this.success,
    required this.isValid,
    required this.message,
    required this.timestamp,
  });

  factory ServiceValidationResponse.fromJson(Map<String, dynamic> json) {
    return ServiceValidationResponse(
      success: json['success'] ?? false,
      isValid: json['success'] ?? false, // If success, assume valid unless contradicted
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }

  factory ServiceValidationResponse.isValid({
    required String message,
    required String timestamp, required bool isValid,
  }) {
    return ServiceValidationResponse(
      success: true,
      isValid: true,
      message: message,
      timestamp: timestamp,
    );
  }
  factory ServiceValidationResponse.notValid({
    required String message,
     String? timestamp,  bool isValid = false,
  }) {
    return ServiceValidationResponse(
      success: false,
      isValid: isValid,
      message: message,
      timestamp: timestamp ?? DateTime.timestamp().toString(),
    );
  }


  @override
  List<Object?> get props => [success, isValid, message, timestamp];
}