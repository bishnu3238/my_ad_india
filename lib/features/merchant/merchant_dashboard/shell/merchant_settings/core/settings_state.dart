import 'package:flutter/material.dart';
import 'settings_repository.dart';

enum SettingsLoadingState { idle, loading, success, error }

enum NotificationFrequency { immediate, hourly, daily, weekly }

enum DataSyncInterval { realtime, minutes5, minutes15, minutes30, hourly }

class SettingsState extends ChangeNotifier {
  // Loading and Error States
  SettingsLoadingState _loadingState = SettingsLoadingState.idle;
  String? _errorMessage;

  // User Profile Settings
  String _businessName = '';
  String _contactEmail = '';
  String _phoneNumber = '';
  String _businessAddress = '';
  String _businessDescription = '';
  String _businessCategory = 'General';

  // Service Configuration
  bool _serviceEnabled = true;
  bool _autoAcceptOrders = false;
  int _maxConcurrentOrders = 10;
  double _serviceFeePercentage = 2.5;

  // Notification Settings
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _smsNotificationsEnabled = false;
  NotificationFrequency _notificationFrequency = NotificationFrequency.immediate;

  // Data & Privacy Settings
  bool _analyticsEnabled = true;
  bool _dataSharingEnabled = false;
  DataSyncInterval _dataSyncInterval = DataSyncInterval.minutes15;
  bool _backupEnabled = true;

  // Security Settings
  bool _twoFactorEnabled = false;
  bool _biometricAuthEnabled = false;
  int _sessionTimeoutMinutes = 30;

  // Display Settings
  bool _darkModeEnabled = false;
  double _fontSize = 16.0;
  String _language = 'English';

  // Getters
  SettingsLoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _loadingState == SettingsLoadingState.loading;
  bool get hasError => _loadingState == SettingsLoadingState.error;

  // Business Profile Getters
  String get businessName => _businessName;
  String get contactEmail => _contactEmail;
  String get phoneNumber => _phoneNumber;
  String get businessAddress => _businessAddress;
  String get businessDescription => _businessDescription;
  String get businessCategory => _businessCategory;

  // Service Configuration Getters
  bool get serviceEnabled => _serviceEnabled;
  bool get autoAcceptOrders => _autoAcceptOrders;
  int get maxConcurrentOrders => _maxConcurrentOrders;
  double get serviceFeePercentage => _serviceFeePercentage;

  // Notification Getters
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;
  bool get emailNotificationsEnabled => _emailNotificationsEnabled;
  bool get smsNotificationsEnabled => _smsNotificationsEnabled;
  NotificationFrequency get notificationFrequency => _notificationFrequency;

  // Data & Privacy Getters
  bool get analyticsEnabled => _analyticsEnabled;
  bool get dataSharingEnabled => _dataSharingEnabled;
  DataSyncInterval get dataSyncInterval => _dataSyncInterval;
  bool get backupEnabled => _backupEnabled;

  // Security Getters
  bool get twoFactorEnabled => _twoFactorEnabled;
  bool get biometricAuthEnabled => _biometricAuthEnabled;
  int get sessionTimeoutMinutes => _sessionTimeoutMinutes;

  // Display Getters
  bool get darkModeEnabled => _darkModeEnabled;
  double get fontSize => _fontSize;
  String get language => _language;

  // State Management Methods
  void setLoadingState(SettingsLoadingState state) {
    _loadingState = state;
    notifyListeners();
  }

  void setError(String error) {
    _errorMessage = error;
    _loadingState = SettingsLoadingState.error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_loadingState == SettingsLoadingState.error) {
      _loadingState = SettingsLoadingState.idle;
    }
    notifyListeners();
  }

  // Business Profile Methods
  void updateBusinessName(String name) {
    _businessName = name;
    notifyListeners();
  }

  void updateContactEmail(String email) {
    _contactEmail = email;
    notifyListeners();
  }

  void updatePhoneNumber(String phone) {
    _phoneNumber = phone;
    notifyListeners();
  }

  void updateBusinessAddress(String address) {
    _businessAddress = address;
    notifyListeners();
  }

  void updateBusinessDescription(String description) {
    _businessDescription = description;
    notifyListeners();
  }

  void updateBusinessCategory(String category) {
    _businessCategory = category;
    notifyListeners();
  }

  // Service Configuration Methods
  void toggleServiceEnabled() {
    _serviceEnabled = !_serviceEnabled;
    notifyListeners();
  }

  void toggleAutoAcceptOrders() {
    _autoAcceptOrders = !_autoAcceptOrders;
    notifyListeners();
  }

  void updateMaxConcurrentOrders(int max) {
    _maxConcurrentOrders = max;
    notifyListeners();
  }

  void updateServiceFeePercentage(double fee) {
    _serviceFeePercentage = fee;
    notifyListeners();
  }

  // Notification Methods
  void togglePushNotifications() {
    _pushNotificationsEnabled = !_pushNotificationsEnabled;
    notifyListeners();
  }

  void toggleEmailNotifications() {
    _emailNotificationsEnabled = !_emailNotificationsEnabled;
    notifyListeners();
  }

  void toggleSmsNotifications() {
    _smsNotificationsEnabled = !_smsNotificationsEnabled;
    notifyListeners();
  }

  void updateNotificationFrequency(NotificationFrequency frequency) {
    _notificationFrequency = frequency;
    notifyListeners();
  }

  // Data & Privacy Methods
  void toggleAnalytics() {
    _analyticsEnabled = !_analyticsEnabled;
    notifyListeners();
  }

  void toggleDataSharing() {
    _dataSharingEnabled = !_dataSharingEnabled;
    notifyListeners();
  }

  void updateDataSyncInterval(DataSyncInterval interval) {
    _dataSyncInterval = interval;
    notifyListeners();
  }

  void toggleBackup() {
    _backupEnabled = !_backupEnabled;
    notifyListeners();
  }

  // Security Methods
  void toggleTwoFactor() {
    _twoFactorEnabled = !_twoFactorEnabled;
    notifyListeners();
  }

  void toggleBiometricAuth() {
    _biometricAuthEnabled = !_biometricAuthEnabled;
    notifyListeners();
  }

  void updateSessionTimeout(int minutes) {
    _sessionTimeoutMinutes = minutes;
    notifyListeners();
  }

  // Display Methods
  void toggleDarkMode() {
    _darkModeEnabled = !_darkModeEnabled;
    notifyListeners();
  }

  void updateFontSize(double size) {
    _fontSize = size;
    notifyListeners();
  }

  void updateLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  // Data Loading and Saving
  Future<void> loadSettings() async {
    setLoadingState(SettingsLoadingState.loading);
    try {
      final settings = await SettingsRepository.loadSettings();
      if (settings != null) {
        _businessName = settings['businessName'] ?? '';
        _contactEmail = settings['contactEmail'] ?? '';
        _phoneNumber = settings['phoneNumber'] ?? '';
        _businessAddress = settings['businessAddress'] ?? '';
        _businessDescription = settings['businessDescription'] ?? '';
        _businessCategory = settings['businessCategory'] ?? 'General';
        _serviceEnabled = settings['serviceEnabled'] ?? true;
        _autoAcceptOrders = settings['autoAcceptOrders'] ?? false;
        _maxConcurrentOrders = settings['maxConcurrentOrders'] ?? 10;
        _serviceFeePercentage = settings['serviceFeePercentage'] ?? 2.5;
        _pushNotificationsEnabled = settings['pushNotificationsEnabled'] ?? true;
        _emailNotificationsEnabled = settings['emailNotificationsEnabled'] ?? true;
        _smsNotificationsEnabled = settings['smsNotificationsEnabled'] ?? false;
        _notificationFrequency = NotificationFrequency.values[settings['notificationFrequency'] ?? 0];
        _analyticsEnabled = settings['analyticsEnabled'] ?? true;
        _dataSharingEnabled = settings['dataSharingEnabled'] ?? false;
        _dataSyncInterval = DataSyncInterval.values[settings['dataSyncInterval'] ?? 2];
        _backupEnabled = settings['backupEnabled'] ?? true;
        _twoFactorEnabled = settings['twoFactorEnabled'] ?? false;
        _biometricAuthEnabled = settings['biometricAuthEnabled'] ?? false;
        _sessionTimeoutMinutes = settings['sessionTimeoutMinutes'] ?? 30;
        _darkModeEnabled = settings['darkModeEnabled'] ?? false;
        _fontSize = settings['fontSize'] ?? 16.0;
        _language = settings['language'] ?? 'English';
        setLoadingState(SettingsLoadingState.success);
      } else {
        setLoadingState(SettingsLoadingState.idle);
      }
    } catch (e) {
      setError("Failed to load settings: ${e.toString()}");
    }
    notifyListeners();
  }

  Future<void> saveSettings() async {
    setLoadingState(SettingsLoadingState.loading);
    try {
      await SettingsRepository.saveSettings(this);
      setLoadingState(SettingsLoadingState.success);
    } catch (e) {
      setError("Failed to save settings: ${e.toString()}");
    }
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    setLoadingState(SettingsLoadingState.loading);
    try {
      _businessName = '';
      _contactEmail = '';
      _phoneNumber = '';
      _businessAddress = '';
      _businessDescription = '';
      _businessCategory = 'General';
      _serviceEnabled = true;
      _autoAcceptOrders = false;
      _maxConcurrentOrders = 10;
      _serviceFeePercentage = 2.5;
      _pushNotificationsEnabled = true;
      _emailNotificationsEnabled = true;
      _smsNotificationsEnabled = false;
      _notificationFrequency = NotificationFrequency.immediate;
      _analyticsEnabled = true;
      _dataSharingEnabled = false;
      _dataSyncInterval = DataSyncInterval.minutes15;
      _backupEnabled = true;
      _twoFactorEnabled = false;
      _biometricAuthEnabled = false;
      _sessionTimeoutMinutes = 30;
      _darkModeEnabled = false;
      _fontSize = 16.0;
      _language = 'English';
      setLoadingState(SettingsLoadingState.success);
    } catch (e) {
      setError("Failed to reset settings: ${e.toString()}");
    }
    notifyListeners();
  }
}