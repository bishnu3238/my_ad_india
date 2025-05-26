import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../provider_state/theme_provider.dart';
import 'notification_manager.dart';
import 'service_manager.dart';
import 'settings_state.dart';
import 'settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsState _settingsState = SettingsState();

  SettingsState get state => _settingsState;

  SettingsProvider(BuildContext context) {
    _initializeSettings(context);
  }

  Future<void> _initializeSettings(BuildContext context) async {
    try {
      await _loadSettingsFromStorage(context);
    } catch (e) {
      _settingsState.setError("Failed to initialize settings: ${e.toString()}");
    }
  }

  Future<void> _loadSettingsFromStorage(BuildContext context) async {
    final savedSettings = await SettingsRepository.loadSettings();
    if (savedSettings != null) {
      _applyLoadedSettings(savedSettings, context);
    }
  }

  void _applyLoadedSettings(
    Map<String, dynamic> settings,
    BuildContext context,
  ) {
    try {
      _settingsState.updateBusinessName(settings['businessName'] ?? '');
      _settingsState.updateContactEmail(settings['contactEmail'] ?? '');
      _settingsState.updatePhoneNumber(settings['phoneNumber'] ?? '');
      _settingsState.updateBusinessAddress(settings['businessAddress'] ?? '');
      _settingsState.updateBusinessDescription(
        settings['businessDescription'] ?? '',
      );
      _settingsState.updateBusinessCategory(
        settings['businessCategory'] ?? 'General',
      );

      // Sync with ServiceManager
      final serviceManager = Provider.of<ServiceManager>(
        context,
        listen: false,
      );
      serviceManager.toggleServiceEnabled(_settingsState.serviceEnabled);
      serviceManager.toggleAutoAcceptOrders(_settingsState.autoAcceptOrders);
      serviceManager.setMaxConcurrentOrders(_settingsState.maxConcurrentOrders);
      serviceManager.setServiceFeePercentage(
        _settingsState.serviceFeePercentage,
      );

      // _settingsState.toggleServiceEnabled();
      // _settingsState.toggleAutoAcceptOrders();
      // _settingsState.updateMaxConcurrentOrders(settings['maxConcurrentOrders'] ?? 10);
      // _settingsState.updateServiceFeePercentage(settings['serviceFeePercentage'] ?? 2.5);
      // Sync with NotificationManager
      final notificationManager = Provider.of<NotificationManager>(
        context,
        listen: false,
      );
      notificationManager.togglePushNotifications(
        _settingsState.pushNotificationsEnabled,
      );
      notificationManager.toggleEmailNotifications(
        _settingsState.emailNotificationsEnabled,
      );
      notificationManager.toggleSmsNotifications(
        _settingsState.smsNotificationsEnabled,
      );
      notificationManager.setNotificationFrequency(
        _settingsState.notificationFrequency,
      );

      // Sync with AppThemeProvider
      final themeProvider = Provider.of<AppThemeProvider>(
        context,
        listen: false,
      );
      themeProvider.setThemeMode(
        _settingsState.darkModeEnabled ? AppThemeMode.dark : AppThemeMode.light,
      );
      // _settingsState.togglePushNotifications();
      // _settingsState.toggleEmailNotifications();
      // _settingsState.toggleSmsNotifications();
      // _settingsState.updateNotificationFrequency(
      //   NotificationFrequency.values[settings['notificationFrequency'] ?? 0],
      // );

      _settingsState.toggleAnalytics();
      _settingsState.toggleDataSharing();
      _settingsState.updateDataSyncInterval(
        DataSyncInterval.values[settings['dataSyncInterval'] ?? 2],
      );
      _settingsState.toggleBackup();

      _settingsState.toggleTwoFactor();
      _settingsState.toggleBiometricAuth();
      _settingsState.updateSessionTimeout(
        settings['sessionTimeoutMinutes'] ?? 30,
      );

      // _settingsState.toggleDarkMode();
      _settingsState.updateFontSize(settings['fontSize'] ?? 16.0);
      _settingsState.updateLanguage(settings['language'] ?? 'English');

      notifyListeners();
    } catch (e) {
      _settingsState.setError(
        "Failed to apply loaded settings: ${e.toString()}",
      );
    }
  }

  // Business Profile Methods
  Future<void> updateBusinessProfile({
    required String businessName,
    required String contactEmail,
    required String phoneNumber,
    required String businessAddress,
    required String businessDescription,
    required String businessCategory,
  }) async {
    final validationError = SettingsRepository.validateBusinessProfile(
      businessName: businessName,
      contactEmail: contactEmail,
      phoneNumber: phoneNumber,
    );

    if (validationError != null) {
      _settingsState.setError(validationError);
      return;
    }

    _settingsState.clearError();
    _settingsState.updateBusinessName(businessName);
    _settingsState.updateContactEmail(contactEmail);
    _settingsState.updatePhoneNumber(phoneNumber);
    _settingsState.updateBusinessAddress(businessAddress);
    _settingsState.updateBusinessDescription(businessDescription);
    _settingsState.updateBusinessCategory(businessCategory);

    await _saveSettings();

    await SettingsRepository.saveBusinessProfile(
      businessName: businessName,
      contactEmail: contactEmail,
      phoneNumber: phoneNumber,
      businessAddress: businessAddress,
      businessDescription: businessDescription,
      businessCategory: businessCategory,
    );
  }

  // Service Configuration Methods
  Future<void> toggleService() async {
    _settingsState.toggleServiceEnabled();
    await _saveSettings();
  }

  Future<void> toggleAutoAcceptOrders() async {
    _settingsState.toggleAutoAcceptOrders();
    await _saveSettings();
  }

  Future<void> updateMaxConcurrentOrders(int max) async {
    if (max < 1 || max > 100) {
      _settingsState.setError(
        "Maximum concurrent orders must be between 1 and 100",
      );
      return;
    }
    _settingsState.clearError();
    _settingsState.updateMaxConcurrentOrders(max);
    await _saveSettings();
  }

  Future<void> updateServiceFeePercentage(double fee) async {
    if (fee < 0 || fee > 20) {
      _settingsState.setError("Service fee must be between 0% and 20%");
      return;
    }
    _settingsState.clearError();
    _settingsState.updateServiceFeePercentage(fee);
    await _saveSettings();
  }

  // Notification Methods
  Future<void> togglePushNotifications() async {
    _settingsState.togglePushNotifications();
    await _saveSettings();
  }

  Future<void> toggleEmailNotifications() async {
    _settingsState.toggleEmailNotifications();
    await _saveSettings();
  }

  Future<void> toggleSmsNotifications() async {
    _settingsState.toggleSmsNotifications();
    await _saveSettings();
  }

  Future<void> updateNotificationFrequency(
    NotificationFrequency frequency,
  ) async {
    _settingsState.updateNotificationFrequency(frequency);
    await _saveSettings();
  }

  // Data & Privacy Methods
  Future<void> toggleAnalytics() async {
    _settingsState.toggleAnalytics();
    await _saveSettings();
  }

  Future<void> toggleDataSharing() async {
    _settingsState.toggleDataSharing();
    await _saveSettings();
  }

  Future<void> updateDataSyncInterval(DataSyncInterval interval) async {
    _settingsState.updateDataSyncInterval(interval);
    await _saveSettings();
  }

  Future<void> toggleBackup() async {
    _settingsState.toggleBackup();
    await _saveSettings();
  }

  // Security Methods
  Future<void> toggleTwoFactor() async {
    _settingsState.toggleTwoFactor();
    await _saveSettings();
  }

  Future<void> toggleBiometricAuth() async {
    _settingsState.toggleBiometricAuth();
    await _saveSettings();
  }

  Future<void> updateSessionTimeout(int minutes) async {
    if (minutes < 5 || minutes > 480) {
      _settingsState.setError(
        "Session timeout must be between 5 minutes and 8 hours",
      );
      return;
    }
    _settingsState.clearError();
    _settingsState.updateSessionTimeout(minutes);
    await _saveSettings();
  }

  // Display Methods
  Future<void> toggleDarkMode(BuildContext context) async {
    _settingsState.toggleDarkMode();
    final themeProvider = Provider.of<AppThemeProvider>(context, listen: false);
    themeProvider.setThemeMode(
      _settingsState.darkModeEnabled ? AppThemeMode.dark : AppThemeMode.light,
    );
    await _saveSettings();
  }

  Future<void> updateFontSize(double size) async {
    if (size < 12.0 || size > 24.0) {
      _settingsState.setError("Font size must be between 12 and 24");
      return;
    }
    _settingsState.clearError();
    _settingsState.updateFontSize(size);
    await _saveSettings();
  }

  Future<void> updateLanguage(String language) async {
    _settingsState.updateLanguage(language);
    await _saveSettings();
  }

  Future<void> _saveSettings() async {
    try {
      await SettingsRepository.saveSettings(_settingsState);
    } catch (e) {
      _settingsState.setError("Failed to save settings: ${e.toString()}");
    }
  }

  Future<void> saveAllSettings() async {
    await _settingsState.saveSettings();
  }

  Future<void> loadAllSettings() async {
    await _settingsState.loadSettings();
  }

  Future<void> resetToDefaults(BuildContext context) async {
    await _settingsState.resetToDefaults();
    final themeProvider = Provider.of<AppThemeProvider>(context, listen: false);
    themeProvider.setThemeMode(AppThemeMode.system);
    await SettingsRepository.clearSettings();
  }

  Future<void> backupToCloud() async {
    _settingsState.setLoadingState(SettingsLoadingState.loading);
    try {
      await SettingsRepository.backupToCloud(_settingsState);
      _settingsState.setLoadingState(SettingsLoadingState.success);
    } catch (e) {
      _settingsState.setError("Failed to backup settings: ${e.toString()}");
    }
  }

  Future<void> restoreFromCloud(BuildContext context) async {
    _settingsState.setLoadingState(SettingsLoadingState.loading);
    try {
      final cloudSettings = await SettingsRepository.restoreFromCloud();
      if (cloudSettings != null) {
        _applyLoadedSettings(cloudSettings, context);
        await _saveSettings();
        _settingsState.setLoadingState(SettingsLoadingState.success);
      } else {
        _settingsState.setError("No backup found in cloud");
      }
    } catch (e) {
      _settingsState.setError("Failed to restore settings: ${e.toString()}");
    }
  }

  List<String> getBusinessCategories() =>
      SettingsRepository.getBusinessCategories();
  List<String> getAvailableLanguages() =>
      SettingsRepository.getAvailableLanguages();

  void clearError() => _settingsState.clearError();
}

class SettingsProviderWrapper extends StatelessWidget {
  final Widget child;

  const SettingsProviderWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(context),
      child: child,
    );
  }
}
