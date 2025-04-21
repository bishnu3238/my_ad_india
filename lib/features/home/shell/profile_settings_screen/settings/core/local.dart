import 'package:dartz/dartz.dart';
import 'package:pack/services/failure/failure.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LocalAppSettingStorage {
  static const String LANGUAGE_KEY = 'app_language';
  static const String NOTIFICATIONS_KEY = 'notifications_enabled';
  static const String FULL_NOTIFICATIONS_KEY = 'full_page_notifications_enabled';
  static const String COUNTRY_KEY = 'user_country';

  Future<Result<String>> getLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return Right(prefs.getString(LANGUAGE_KEY) ?? 'en');
    } catch (e) {
      return Left(
        StorageFailure('Failed to load language setting: ${e.toString()}'),
      );
    }
  }

  Future<Result<bool>> saveLanguage(String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(LANGUAGE_KEY, language);
      return const Right(true);
    } catch (e) {
      return Left(
        StorageFailure('Failed to save language setting: ${e.toString()}'),
      );
    }
  }

  Future<Result<bool>> getNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return Right(prefs.getBool(NOTIFICATIONS_KEY) ?? true);
    } catch (e) {
      return Left(
        StorageFailure('Failed to load notifications setting: ${e.toString()}'),
      );
    }
  }

  Future<Result<bool>> saveNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(NOTIFICATIONS_KEY, enabled);
      return const Right(true);
    } catch (e) {
      return Left(
        StorageFailure('Failed to save notifications setting: ${e.toString()}'),
      );
    }
  }  Future<Result<bool>> getFullPageNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return Right(prefs.getBool(FULL_NOTIFICATIONS_KEY) ?? true);
    } catch (e) {
      return Left(
        StorageFailure('Failed to load notifications setting: ${e.toString()}'),
      );
    }
  }

  Future<Result<bool>> saveFullPageNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(FULL_NOTIFICATIONS_KEY, enabled);
      return const Right(true);
    } catch (e) {
      return Left(
        StorageFailure('Failed to save notifications setting: ${e.toString()}'),
      );
    }
  }

  Future<Result<bool>> clearCache() async {
    try {
      // Simulate cache clearing with a delay
      await Future.delayed(const Duration(seconds: 2));
      return const Right(true);
    } catch (e) {
      return Left(StorageFailure('Failed to clear cache: ${e.toString()}'));
    }
  }

  Future<Result<bool>> saveCountryName(String countryName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(COUNTRY_KEY, countryName);
      return const Right(true);
    } catch (e) {
      return Left(
        StorageFailure('Failed to save country setting: ${e.toString()}'),
      );
    }
  }


  Future<Result<String>?> getCountryName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return Right(prefs.getString(COUNTRY_KEY) ?? 'INDIA');
    } catch (e) {
      return Left(
        StorageFailure('Failed to load country setting: ${e.toString()}'),
      );
    }
  }


}
class StorageFailure extends Failure {
  const StorageFailure([String message = 'Storage operation failed']) : super(message: '');
}

class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Validation failed']) : super(message: '');
}

class PermissionFailure extends Failure {
  const PermissionFailure([String message = 'Permission denied']) : super(message: '');
}

typedef Result<T> = Either<Failure, T>;