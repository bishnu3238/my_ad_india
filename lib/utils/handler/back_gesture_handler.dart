import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/src/route.dart';
import 'package:pack/resources/resources.dart';
import '../../core/injector/dependency_injection.dart';
import '../../features/home/shell/home_screen/core/home_provider.dart';
import 'package:pack/services/service.dart';

import '../widgets/svg_icon_widget.dart';

class BackGestureHandler {
  static DateTime? _lastBackPressTime;
  static const Duration _exitTimeLimit = Duration(seconds: 2);

  static Future<bool> handleBackPress(
    BuildContext context,
    StatefulNavigationShell navigationShell,
  ) async {
    // Check if we're at the root route
    final NavigatorState navigator = Navigator.of(context);
    final bool canPop = navigator.canPop();

    if (!canPop) {
      // We're at the root, so handle app exit logic
      return _handleAppExit(context, navigationShell);
    }

    // If we can pop, let the default back navigation happen
    return true;
  }

  static Future<bool> handleMerchant(BuildContext context, StatefulNavigationShell navigationShell) async {
    // Check if we're at the root route
    final NavigatorState navigator = Navigator.of(context);
    final bool canPop = navigator.canPop();

    if (!canPop) {
      // We're at the root, so handle app exit logic
      return _handleAppExit(context, navigationShell);
    }

    // // If we can pop, let the default back navigation happen
    // return true;
    //
    // if (canPop) {
    //   // We're at the root, so handle app exit logic
    //   final now = DateTime.now();
    //
    //   // Check if back was pressed recently
    //   if (_lastBackPressTime == null ||
    //       now.difference(_lastBackPressTime!) > _exitTimeLimit) {
    //     // First back press or timeout since last press
    //     _lastBackPressTime = now;
    //
    //     // Show exit hint
    //     _showExitSnackBar(context);
    //
    //     // Prevent app from closing
    //     return false;
    //   }
    // }
    // If we can pop, let the default back navigation happen
    return true;
  }

  static Future<bool> _handleAppExit(
    BuildContext context,
    StatefulNavigationShell navigationShell,
  ) async {
    final now = DateTime.now();

    if (navigationShell.currentIndex != 0) {
      navigationShell.goBranch(0, initialLocation: false);
      return false;
    }

    // Check if back was pressed recently
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > _exitTimeLimit) {
      // First back press or timeout since last press
      _lastBackPressTime = now;

      // Show exit hint
      _showExitSnackBar(context);

      // Prevent app from closing
      return false;
    }

    // Second press within time limit - exit the app
    await SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
    return true;
  }

  static void _showExitSnackBar(BuildContext context) {
    NotifyService.googleFilesStyle(
      context: context,
      message: 'Press back again to exit',
      leadingIcon: FaIcon(FontAwesomeIcons.circleInfo),
      // title: '',

      // type: NotificationType.info,
      //
      // showIcon: false,
      // position: NotificationPosition.bottom,
    );
  }
}
