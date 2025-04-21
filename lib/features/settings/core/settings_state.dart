// settings_state.dart
import 'package:my_ad/provider_state/theme_provider.dart';

enum AutoplayOption {
  always,
  wifiOnly,
  never,
}



class SettingsState {
  final String userName;
  final String country;
  final bool notificationsEnabled;
  final bool fullPageNotificationsEnabled;
  final AutoplayOption autoplayOption;
  final AppThemeMode themeOption;
  final String appVersion;
  final bool isLoading;

  SettingsState({
    this.userName = 'UserName',
    this.country = 'India',
    this.notificationsEnabled = true,
    this.fullPageNotificationsEnabled = true,
    this.autoplayOption = AutoplayOption.always,
    this.themeOption = AppThemeMode.system,
    this.appVersion = '1.0.0',
    this.isLoading = false,
  });

  SettingsState copyWith({
    String? userName,
    String? country,
    bool? notificationsEnabled,
    bool? fullPageNotificationsEnabled,
    AutoplayOption? autoplayOption,
    AppThemeMode? themeOption,
    String? appVersion,
    bool? isLoading,
  }) {
    return SettingsState(
      userName: userName ?? this.userName,
      country: country ?? this.country,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      fullPageNotificationsEnabled: fullPageNotificationsEnabled ?? this.fullPageNotificationsEnabled,
      autoplayOption: autoplayOption ?? this.autoplayOption,
      themeOption: themeOption ?? this.themeOption,
      appVersion: appVersion ?? this.appVersion,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}