
/// Response wrapper
class ApiResponse<T> {
  final T? data;
  final int statusCode;
  final Map<String, String>? headers;
  final bool isFromCache;
  final DateTime timestamp;

  ApiResponse({
    this.data,
    required this.statusCode,
    this.headers,
    this.isFromCache = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}