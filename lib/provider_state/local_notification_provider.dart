import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:pack/services/service.dart';

class LocalNotificationProvider extends ChangeNotifier{
  final LocalNotificationService _localNotificationService;
  LocalNotificationProvider(this._localNotificationService){
    _localNotificationService.onNotificationClick.listen((response) {
      // Handle notification click (e.g., navigate or update UI)
      notifyListeners();
    });
  }

  Future<void> init() async {
    await _localNotificationService.init(
      onNotificationResponse: (response) {
        // Handle notification response here
        dev.log("Notification clicked with payload: ${response.payload}");
      },
    );
  }

  Future<int> showNotification(String title, String body) async {
    final id = await _localNotificationService.show(title: title, body: body);
    notifyListeners(); // Notify UI of changes
    return id;
  }

  Future<void> checkPermissions() async {
     final status = await _localNotificationService.checkAndRequestPermission();
    if (status != PermissionStatus.granted) {
      // Handle denial (e.g., show a dialog)
      print('Notification permissions denied');
    }
  }


}