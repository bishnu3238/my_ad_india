import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_state.dart';

class NotificationManager extends ChangeNotifier {
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _smsNotificationsEnabled = false;
  NotificationFrequency _notificationFrequency = NotificationFrequency.immediate;

  bool get pushNotificationsEnabled => _pushNotificationsEnabled;
  bool get emailNotificationsEnabled => _emailNotificationsEnabled;
  bool get smsNotificationsEnabled => _smsNotificationsEnabled;
  NotificationFrequency get notificationFrequency => _notificationFrequency;

  void togglePushNotifications(bool value) {
    _pushNotificationsEnabled = value;
    // Simulate enabling/disabling push notifications
    print('Push notifications ${value ? 'enabled' : 'disabled'}');
    notifyListeners();
  }

  void toggleEmailNotifications(bool value) {
    _emailNotificationsEnabled = value;
    // Simulate enabling/disabling email notifications
    print('Email notifications ${value ? 'enabled' : 'disabled'}');
    notifyListeners();
  }

  void toggleSmsNotifications(bool value) {
    _smsNotificationsEnabled = value;
    // Simulate enabling/disabling SMS notifications
    print('SMS notifications ${value ? 'enabled' : 'disabled'}');
    notifyListeners();
  }

  void setNotificationFrequency(NotificationFrequency frequency) {
    _notificationFrequency = frequency;
    // Simulate scheduling notifications
    print('Notification frequency set to ${frequency.toString()}');
    notifyListeners();
  }
}

