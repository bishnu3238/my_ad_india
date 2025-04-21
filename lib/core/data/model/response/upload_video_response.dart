import 'dart:convert';

import 'package:pack/pack.dart';

class UploadVideoResponse {
  final bool success;
  final String? videoUrl;
  final String message;
  final String timestamp;

  UploadVideoResponse({
    required this.success,
    this.videoUrl,
    required this.message,
    required this.timestamp,
  });

  factory UploadVideoResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return UploadVideoResponse(
      success: json.getBool('success'),
      videoUrl:
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
    'data': videoUrl != null ? {'video_url': videoUrl} : [],
    'message': message,
    'timestamp': timestamp,
  };
}
