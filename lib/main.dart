import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:pack/services/service.dart';
import 'core/data/api/api_config.dart';
import 'package:pack/auth/custom_auth.dart';
import 'core/data/model/user/user_model.dart';
import 'core/injector/dependency_injection.dart';
import 'features/app_start/app.dart';

void main() async {
  /// This is the entry point of the application.
  /// It initializes the Flutter engine and sets up the application.
  WidgetsFlutterBinding.ensureInitialized();

  /// TODO: uncomment if later for this project uses
  // await NotificationService.init();
  await CustomAuth.init(
    baseUrl: ApiConfig.authBaseUrl,
    userFromJson: UserModel.fromJson,
    loginEndpoint: ApiConfig.login,
    otpEndpoint: ApiConfig.otp,
    signupEndpoint: ApiConfig.signUp,
    changePasswordEndpoint: ApiConfig.changePassword,
    forgotPasswordEndpoint: ApiConfig.forgotPassword,
    logoutEndpoint: ApiConfig.logout,
    defaultTimeout: Duration(seconds: 50),
    enableSocialLogin: false,
  );

  /// Initialize the dependency injector
  DependencyInjector.setup();

  /// Initialize the local notification service
  await _initializeNotifications();

  /// Initialize the app
  runApp(App());
}

Future<void> _initializeNotifications() async {
  final notificationService =
      DependencyInjector.get<LocalNotificationService>();

  await notificationService
      .init(
        onNotificationResponse: (response) {
          ///TODO: handle notification response
          dev.log("NOTIFICATION RESPONSE = ${response.data}");
        },
      )
      .then(
        (value) =>
            dev.log("QUESTION: IS NOTIFICATION INITIALIZE?. ANS: $value"),
      );

  // Request notification permissions
  await notificationService.checkAndRequestPermission().then((value) async {
    dev.log(
      "QUESTION: IS NOTIFICATION PERMISSION GRANTED?. ANS: ${value.name}",
    );

    if (value == PermissionStatus.granted) {
    } else if (value == PermissionStatus.denied) {
      await notificationService.checkAndRequestPermission();
    } else if (value == PermissionStatus.unknown) {
      await notificationService.checkAndRequestPermission();
    }
  });
}

/// TODO: run this command for running node server;
//Set-ExecutionPolicy Bypass -Scope Process -Force
