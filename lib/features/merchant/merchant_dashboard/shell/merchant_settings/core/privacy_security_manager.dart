import 'package:flutter/material.dart';
import 'settings_state.dart';

class PrivacySecurityManager extends ChangeNotifier {
  bool _analyticsEnabled = true;
  bool _dataSharingEnabled = false;
  bool _backupEnabled = true;
  DataSyncInterval _dataSyncInterval = DataSyncInterval.minutes15;
  bool _twoFactorEnabled = false;
  bool _biometricAuthEnabled = false;
  int _sessionTimeoutMinutes = 30;

  bool get analyticsEnabled => _analyticsEnabled;
  bool get dataSharingEnabled => _dataSharingEnabled;
  bool get backupEnabled => _backupEnabled;
  DataSyncInterval get dataSyncInterval => _dataSyncInterval;
  bool get twoFactorEnabled => _twoFactorEnabled;
  bool get biometricAuthEnabled => _biometricAuthEnabled;
  int get sessionTimeoutMinutes => _sessionTimeoutMinutes;

  void toggleAnalytics(bool value) {
    _analyticsEnabled = value;
    // Simulate enabling/disabling analytics
    print('Analytics ${value ? 'enabled' : 'disabled'}');
    notifyListeners();
  }

  void toggleDataSharing(bool value) {
    _dataSharingEnabled = value;
    // Simulate enabling/disabling data sharing
    print('Data sharing ${value ? 'enabled' : 'disabled'}');
    notifyListeners();
  }

  void toggleBackup(bool value) {
    _backupEnabled = value;
    // Simulate enabling/disabling automatic backup
    print('Automatic backup ${value ? 'enabled' : 'disabled'}');
    notifyListeners();
  }

  void setDataSyncInterval(DataSyncInterval interval) {
    _dataSyncInterval = interval;
    // Simulate setting data sync interval
    print('Data sync interval set to ${interval.toString()}');
    notifyListeners();
  }

  void toggleTwoFactor(bool value) {
    _twoFactorEnabled = value;
    // Simulate enabling/disabling two-factor authentication
    print('Two-factor authentication ${value ? 'enabled' : 'disabled'}');
    notifyListeners();
  }

  void toggleBiometricAuth(bool value) {
    _biometricAuthEnabled = value;
    // Simulate enabling/disabling biometric authentication
    print('Biometric authentication ${value ? 'enabled' : 'disabled'}');
    notifyListeners();
  }

  void setSessionTimeout(int minutes) {
    _sessionTimeoutMinutes = minutes;
    // Simulate setting session timeout
    print('Session timeout set to $minutes minutes');
    notifyListeners();
  }
}

