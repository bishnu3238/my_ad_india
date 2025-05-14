// settings_view_model.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pack/services/service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/data/model/model.dart';
import '../../../provider_state/theme_provider.dart';
import '../../home/shell/profile_settings_screen/settings/core/local.dart';
import 'settings_state.dart';

class SettingsViewModel extends ChangeNotifier {
  final UserModel _user;
  final AppVersionTracker _appVersionTracker;
  final LocalAppSettingStorage _storageService;
  final AppThemeProvider _appThemeProvider;

  SettingsState _state = SettingsState();
  bool _initialized = false;

  SettingsState get state => _state;

  SettingsViewModel(
    this._appThemeProvider,
    this._appVersionTracker, {
    required UserModel user,
  }) : _user = user,
       _storageService = LocalAppSettingStorage() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    if (_initialized) return;

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load user settings
      final userName = _user.name;
      final country = await _storageService.getCountryName().then(
        (value) => value?.getRight(),
      );

      // Load notification settings
      final notificationsEnabled =await _storageService.getNotificationsEnabled().then((value)=>value.getRight());
      final fullPageNotificationsEnabled =await
          _storageService.getFullPageNotificationsEnabled().then((value)=>value.getRight());

      // Load autoplay settings
      final autoplayValue =
          prefs.getInt('autoplay_option') ?? AutoplayOption.always.index;
      final autoplayOption = AutoplayOption.values[autoplayValue];

      // Load theme settings
      final themeValue = _appThemeProvider.currentThemeMode;

      // Load app version
      final appVersion = _appVersionTracker.appVersion;

      _state = _state.copyWith(
        userName: userName,
        country: country,
        notificationsEnabled: notificationsEnabled,
        fullPageNotificationsEnabled: fullPageNotificationsEnabled,
        autoplayOption: autoplayOption,
        themeOption: themeValue,
        appVersion: appVersion,
        isLoading: false,
      );

      _initialized = true;
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save notification settings
      await prefs.setBool('notifications_enabled', _state.notificationsEnabled);
      await prefs.setBool(
        'full_page_notifications',
        _state.fullPageNotificationsEnabled,
      );

      // Save autoplay settings
      await prefs.setInt('autoplay_option', _state.autoplayOption.index);

      // Save theme settings
      await prefs.setInt('theme_option', _state.themeOption.index);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  // Update methods
  void updateNotificationsEnabled(bool value) {
    _state = _state.copyWith(notificationsEnabled: value);
    _saveSettings();
    notifyListeners();
  }

  void updateFullPageNotifications(bool value) {
    _state = _state.copyWith(fullPageNotificationsEnabled: value);
    _saveSettings();
    notifyListeners();
  }

  void updateAutoplayOption(AutoplayOption value) {
    _state = _state.copyWith(autoplayOption: value);
    _saveSettings();
    notifyListeners();
  }

  void updateThemeOption(AppThemeMode value) {
    _state = _state.copyWith(themeOption: value);
    _saveSettings();
    notifyListeners();
  }

  // Navigation methods
  void navigateToEditProfile(BuildContext context) {
    // Navigate to edit profile screen
    debugPrint('Navigate to edit profile');
  }

  void navigateToCountrySelection(BuildContext context) {
    // Navigate to country selection screen
    debugPrint('Navigate to country selection');
  }

  void navigateToNotificationSettings(BuildContext context) {
    // Navigate to notification settings screen
    debugPrint('Navigate to notification settings');
  }

  void navigateToAppInfo(BuildContext context) {
    // Navigate to app info screen
    debugPrint('Navigate to app info');
  }

  void navigateToSecuritySettings(BuildContext context) {
    // Navigate to security settings screen
    debugPrint('Navigate to security settings');
  }

  void navigateToPrivacySettings(BuildContext context) {
    // Navigate to privacy settings screen
    debugPrint('Navigate to privacy settings');
  }

  void navigateToCopyright(BuildContext context) {
    // Navigate to copyright screen
    debugPrint('Navigate to copyright');
  }

  void navigateToTerms(BuildContext context) {
    // Navigate to terms screen
    debugPrint('Navigate to terms');
  }

  void navigateToPrivacyPolicy(BuildContext context) {
    // Navigate to privacy policy screen
    debugPrint('Navigate to privacy policy');
  }

  void navigateToThirdPartyNotices(BuildContext context) {
    // Navigate to third party notices screen
    debugPrint('Navigate to third party notices');
  }

  void navigateToSupport(BuildContext context) {
    context.push('/support');
  }
}
