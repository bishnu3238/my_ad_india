import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'log_service.dart';

/// Token management service
class AuthService {
  final FlutterSecureStorage _storage;
  final LogService _logger;
  static const String _tokenKey = 'auth_token';

  AuthService(this._logger, {FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
      _logger.debug('Token saved');
    } catch (e, stack) {
      _logger.error('Failed to save token', e, stack);
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e, stack) {
      _logger.error('Failed to retrieve token', e, stack);
      return null;
    }
  }

  Future<bool> isTokenValid() async {
    final token = await getToken();
    return token != null; // Add JWT validation if needed
  }

  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
      _logger.debug('Token deleted');
    } catch (e, stack) {
      _logger.error('Failed to delete token', e, stack);
    }
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    if (token != null) {
      return {'Authorization': 'Bearer $token'};
    }
    return {};
  }
}
