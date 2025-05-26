import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../screens/call/call_screen.dart';
import 'socket_services.dart';

// Global navigator key to access context from outside of widgets
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class CallNotificationService {
  static final CallNotificationService _instance = CallNotificationService._internal();
  factory CallNotificationService() => _instance;
  CallNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  StreamSubscription? _incomingCallSubscription;

  Future<void> initialize(SocketService socketService) async {
    // Initialize notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Listen for incoming calls
    _incomingCallSubscription = socketService.onCallEvent.listen(_handleIncomingCall);
  }

  void _handleIncomingCall(Map<String, dynamic> data) async {
    final callId = data['callId']?.toString() ?? '0';
    final conversationId = data['conversationId']?.toString() ?? '0';
    final callerType = data['callerType']?.toString() ?? '';
    final callerId = data['callerId']?.toString() ?? '';
    final callType = data['callType']?.toString() ?? '';
    final callerName = data['callerName']?.toString() ?? 'Unknown';
    final callerImage = data['callerImage']?.toString() ?? '';

    // Show notification for incoming call
    await _showCallNotification(
      callId: callId,
      conversationId: conversationId,
      callerType: callerType,
      callerId: callerId,
      callType: callType,
      callerName: callerName,
      callerImage: callerImage,
    );

    // Also show in-app call screen if app is in foreground
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(
            isIncoming: true,
            callData: {
              'callId': callId,
              'conversationId': conversationId,
              'callerType': callerType,
              'callerId': callerId,
              'callType': callType,
              'callerName': callerName,
              'callerImage': callerImage,
            },
          ),
        ),
      );
    }
  }

  Future<void> _showCallNotification({
    required String callId,
    required String conversationId,
    required String callerType,
    required String callerId,
    required String callType,
    required String callerName,
    required String callerImage,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'call_channel',
      'Incoming Calls',
      channelDescription: 'Notifications for incoming calls',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.call,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      int.parse(callId), // Use callId as notification ID
      'Incoming ${callType.capitalize()} Call',
      'From $callerName',
      notificationDetails,
      payload: '$callId|$conversationId|$callerType|$callerId|$callType|$callerName|$callerImage',
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      final parts = response.payload!.split('|');
      if (parts.length >= 7) {
        final callId = parts[0];
        final conversationId = parts[1];
        final callerType = parts[2];
        final callerId = parts[3];
        final callType = parts[4];
        final callerName = parts[5];
        final callerImage = parts[6];

        final context = navigatorKey.currentContext;
        if (context != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CallScreen(
                isIncoming: false, callData: {} ,

              ),
            ),
          );
        }
      }
    }
  }

  void dispose() {
    _incomingCallSubscription?.cancel();
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return '';
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

