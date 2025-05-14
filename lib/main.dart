import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:pack/services/service.dart';
import 'core/data/api/api_config.dart';
import 'package:pack/auth/custom_auth.dart';
import 'core/data/model/user/user_model.dart';
import 'core/injector/dependency_injection.dart';
import 'features/app_start/app.dart';
import 'dart:io';

import 'features/chat_feature/core/services/call_notification_service.dart';
import 'features/chat_feature/core/services/socket_services.dart';

void main() async {
  /// This is the entry point of the application.
  /// It initializes the Flutter engine and sets up the application.
  WidgetsFlutterBinding.ensureInitialized();

  /// TODO: uncomment if later for this project uses
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
  CallNotificationService().initialize(DependencyInjector.get<SocketService>());
  HttpOverrides.global = MyHttpOverrides();
  runApp(App());

  /// Initialize the app
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
  await notificationService.getPermissionStatus().then((value) async {
    dev.log(
      "QUESTION: IS NOTIFICATION PERMISSION GRANTED?. ANS: ${value.name}",
    );

    if (value == PermissionStatus.granted) {
    } else if (value == PermissionStatus.denied) {
      await notificationService.getPermissionStatus();
    } else if (value == PermissionStatus.unknown) {
      await notificationService.getPermissionStatus();
    }
  });
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

/// TODO: run this command for running node server;
//Set-ExecutionPolicy Bypass -Scope Process -Force

// I have realme x phone and when i run this app in my phone it

// http://inbox.bulksmswale.in/sendsms.jsp?user=xxxxxx&password=xxxxxxxxxxXX&senderid=xxxxxx&entityid=xxxxxxxxxxxxxxxxxxx&tempid=xxxxxxxxxxxxxxxxxxx&mobiles=xxxxxxxxxx&sms=%7B%23var%23%7D%20is%20the%20OTP%20to%20login%20at%20https%3A%2F%2Fdomainoxxx.com%2Fdoma-doctor%2Fdoctor_signin.php%0AOTPs%20are%20SECRET.%20DO%20NOT%20disclose%20it%20to%20anyone.%0A-xxxxxx
// http://inbox.bulksmswale.in/sendsms.jsp?user=EAZYTC&password=734a73d6feXX&senderid=EAZYTC&entityid=1501413500000036227&tempid=1707173104531911463&mobiles=8697444166&sms=%7B%23var%23%7D%20is%20the%20OTP%20to%20login%20at%20https%3A%2F%2Feazytechno.com%2Feazy-doctor%2Fdoctor_signin.php%0AOTPs%20are%20SECRET.%20DO%20NOT%20disclose%20it%20to%20anyone.%0A-EAZYTC
