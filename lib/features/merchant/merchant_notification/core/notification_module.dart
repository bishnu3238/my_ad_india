// notification_module.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'notification_model.dart';
import '../notification_page.dart';
import 'notification_provider.dart';
import 'notification_service.dart';
import '../body/notification_counter_widget.dart';

/// Factory to set up all notification-related dependencies
class NotificationModule {
  // Create the notification service and provider
  static NotificationService createNotificationService() {
    return NotificationService();
  }

  static NotificationProvider createNotificationProvider(
    NotificationService service,
  ) {
    return NotificationProvider(service);
  }

  // Set up providers
  static List<SingleChildWidget> providers() {
    return [
      Provider<NotificationService>(create: (_) => createNotificationService()),
      ChangeNotifierProvider<NotificationProvider>(
        create:
            (context) => createNotificationProvider(
              Provider.of<NotificationService>(context, listen: false),
            ),
      ),
    ];
  }

  // Helper to navigate to the notification page
  static void navigateToNotificationPage(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => NotificationPage()));
  }

  // Create a notification counter widget
  static Widget createNotificationCounter(BuildContext context) {
    return NotificationCounterWidget(
      onPressed: () => navigateToNotificationPage(context),
    );
  }
}
