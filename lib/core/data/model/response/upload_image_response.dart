import 'dart:convert';

import 'package:pack/pack.dart';

class UploadImageResponse {
  final bool success;
  final String? imageUrl;
  final String message;
  final String timestamp;

  UploadImageResponse({
    required this.success,
    this.imageUrl,
    required this.message,
    required this.timestamp,
  });

  factory UploadImageResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return UploadImageResponse(
      success: json.getBool('success'),
      imageUrl:
          data is Map<String, dynamic>
              ? data.getString('image_url') as String?
              : null,
      message: json.getString('message') as String? ?? 'Unknown error',
      timestamp:
          json.getString('timestamp') as String? ??
          DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': imageUrl != null ? {'image_url': imageUrl} : [],
    'message': message,
    'timestamp': timestamp,
  };

  @override
  String toString() {
    return 'UploadImageResponse{success: $success, imageUrl: $imageUrl, message: $message, timestamp: $timestamp}';
  }
}
