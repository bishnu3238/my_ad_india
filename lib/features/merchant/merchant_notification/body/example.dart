// To integrate this in your app, add this in your app's initState:
// Initialize notification service in your app's main.dart or initial setup:
/*
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Your existing providers
        ...NotificationModule.providers(),
      ],
      child: MaterialApp(
        // Your app configuration
      ),
    );
  }
*/

// To use the notification counter in your app bar:
/*
  AppBar(
    actions: [
      NotificationModule.createNotificationCounter(context),
      // Other app bar actions
    ],
  ),
*/

// Modified Header class to integrate notification counter
import 'package:flutter/material.dart';
import 'package:pack/pack.dart';

import '../../merchant_dashboard/shell/dashboard/body/header.dart';
import '../core/notification_module.dart';

class HeaderWithNotification extends StatelessWidget {
  const HeaderWithNotification({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        if (!Responsive.isMobile(context))
          Text("Dashboard", style: Theme.of(context).textTheme.titleLarge),
        if (!Responsive.isMobile(context))
          Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
        Expanded(child: SearchField()),
        NotificationModule.createNotificationCounter(context),
        ProfileCard(),
      ],
    );
  }
}