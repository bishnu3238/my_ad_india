import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/handler/back_gesture_handler.dart';
import '../../home/core/home_navigator.dart';
import 'body/bottom_navigation_bar.dart';
import 'body/merchant_app_drawer.dart';

class MerchantDashboardShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MerchantDashboardShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await BackGestureHandler.handleMerchant(context);
        if (shouldPop && context.mounted) context.go(HomeRoute.home);
      },
      child: Scaffold(
        drawer: AppDrawer(),
        body: navigationShell,
        bottomNavigationBar: CustomFloatingNavBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(index),
        ),
      ),
    );
  }
}
