// settings_repository.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_state.dart';

class SettingsRepository {
  static const String _settingsKey = 'app_settings';
  static const String _businessProfileKey = 'business_profile';

  static SharedPreferences? _prefs;

  static Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Save all settings to local storage
  static Future<void> saveSettings(SettingsState settings) async {
    await _initPrefs();

    final settingsMap = {
      'businessName': settings.businessName,
      'contactEmail': settings.contactEmail,
      'phoneNumber': settings.phoneNumber,
      'businessAddress': settings.businessAddress,
      'businessDescription': settings.businessDescription,
      'businessCategory': settings.businessCategory,
      'serviceEnabled': settings.serviceEnabled,
      'autoAcceptOrders': settings.autoAcceptOrders,
      'maxConcurrentOrders': settings.maxConcurrentOrders,
      'serviceFeePercentage': settings.serviceFeePercentage,
      'pushNotificationsEnabled': settings.pushNotificationsEnabled,
      'emailNotificationsEnabled': settings.emailNotificationsEnabled,
      'smsNotificationsEnabled': settings.smsNotificationsEnabled,
      'notificationFrequency': settings.notificationFrequency.index,
      'analyticsEnabled': settings.analyticsEnabled,
      'dataSharingEnabled': settings.dataSharingEnabled,
      'dataSyncInterval': settings.dataSyncInterval.index,
      'backupEnabled': settings.backupEnabled,
      'twoFactorEnabled': settings.twoFactorEnabled,
      'biometricAuthEnabled': settings.biometricAuthEnabled,
      'sessionTimeoutMinutes': settings.sessionTimeoutMinutes,
      'darkModeEnabled': settings.darkModeEnabled,
      'fontSize': settings.fontSize,
      'language': settings.language,
    };

    await _prefs!.setString(_settingsKey, jsonEncode(settingsMap));
  }

  // Load settings from local storage
  static Future<Map<String, dynamic>?> loadSettings() async {
    await _initPrefs();

    final settingsJson = _prefs!.getString(_settingsKey);
    if (settingsJson != null) {
      return jsonDecode(settingsJson) as Map<String, dynamic>;
    }
    return null;
  }

  // Save business profile separately for quick access
  static Future<void> saveBusinessProfile({
    required String businessName,
    required String contactEmail,
    required String phoneNumber,
    required String businessAddress,
    required String businessDescription,
    required String businessCategory,
  }) async {
    await _initPrefs();

    final profileMap = {
      'businessName': businessName,
      'contactEmail': contactEmail,
      'phoneNumber': phoneNumber,
      'businessAddress': businessAddress,
      'businessDescription': businessDescription,
      'businessCategory': businessCategory,
      'lastUpdated': DateTime.now().toIso8601String(),
    };

    await _prefs!.setString(_businessProfileKey, jsonEncode(profileMap));
  }

  // Load business profile
  static Future<Map<String, dynamic>?> loadBusinessProfile() async {
    await _initPrefs();

    final profileJson = _prefs!.getString(_businessProfileKey);
    if (profileJson != null) {
      return jsonDecode(profileJson) as Map<String, dynamic>;
    }
    return null;
  }

  // Clear all settings
  static Future<void> clearSettings() async {
    await _initPrefs();
    await _prefs!.remove(_settingsKey);
    await _prefs!.remove(_businessProfileKey);
  }

  // Backup settings to cloud (mock implementation)
  static Future<void> backupToCloud(SettingsState settings) async {
    // Simulate cloud backup delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock implementation - replace with actual cloud service
    final settingsData = {
      'businessProfile': {
        'businessName': settings.businessName,
        'contactEmail': settings.contactEmail,
        'phoneNumber': settings.phoneNumber,
        'businessAddress': settings.businessAddress,
        'businessDescription': settings.businessDescription,
        'businessCategory': settings.businessCategory,
      },
      'serviceConfig': {
        'serviceEnabled': settings.serviceEnabled,
        'autoAcceptOrders': settings.autoAcceptOrders,
        'maxConcurrentOrders': settings.maxConcurrentOrders,
        'serviceFeePercentage': settings.serviceFeePercentage,
      },
      'notifications': {
        'pushEnabled': settings.pushNotificationsEnabled,
        'emailEnabled': settings.emailNotificationsEnabled,
        'smsEnabled': settings.smsNotificationsEnabled,
        'frequency': settings.notificationFrequency.index,
      },
      'privacy': {
        'analyticsEnabled': settings.analyticsEnabled,
        'dataSharingEnabled': settings.dataSharingEnabled,
        'dataSyncInterval': settings.dataSyncInterval.index,
        'backupEnabled': settings.backupEnabled,
      },
      'security': {
        'twoFactorEnabled': settings.twoFactorEnabled,
        'biometricAuthEnabled': settings.biometricAuthEnabled,
        'sessionTimeoutMinutes': settings.sessionTimeoutMinutes,
      },
      'display': {
        'darkModeEnabled': settings.darkModeEnabled,
        'fontSize': settings.fontSize,
        'language': settings.language,
      },
      'backupTimestamp': DateTime.now().toIso8601String(),
    };

    // In real implementation, send to cloud service
    print('Backing up settings to cloud: ${jsonEncode(settingsData)}');
  }

  // Restore settings from cloud (mock implementation)
  static Future<Map<String, dynamic>?> restoreFromCloud() async {
    // Simulate cloud restore delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock implementation - replace with actual cloud service
    // Return null if no backup found, or return the settings map
    return null;
  }

  // Validate business profile data
  static String? validateBusinessProfile({
    required String businessName,
    required String contactEmail,
    required String phoneNumber,
  }) {
    if (businessName.trim().isEmpty) {
      return 'Business name is required';
    }

    if (contactEmail.trim().isEmpty) {
      return 'Contact email is required';
    }

    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(contactEmail)) {
      return 'Please enter a valid email address';
    }

    if (phoneNumber.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Basic phone validation
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(phoneNumber)) {
      return 'Please enter a valid phone number';
    }

    return null; // No validation errors
  }

  // Get available business categories
  static List<String> getBusinessCategories() {
    return [
      'General',
      'Technology',
      'Healthcare',
      'Finance',
      'Education',
      'Retail',
      'Food & Beverage',
      'Transportation',
      'Real Estate',
      'Entertainment',
      'Manufacturing',
      'Consulting',
      'Legal',
      'Marketing',
      'Other',
    ];
  }

  // Get available languages
  static List<String> getAvailableLanguages() {
    return [
      'English',
      'Spanish',
      'French',
      'German',
      'Italian',
      'Portuguese',
      'Chinese',
      'Japanese',
      'Korean',
      'Arabic',
    ];
  }
}