import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_ad/utils/includes/app_drawer_wrapper.dart';
import 'body/home_floating_button.dart';

import '../../utils/handler/back_gesture_handler.dart';
import 'body/home_bottom_navigation_bar.dart';

class HomePage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const HomePage({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    onPopInvokedWithResult(didPop, result) async {
      var navigator = Navigator.of(context);
      if (didPop) return;
      final shouldPop = await BackGestureHandler.handleBackPress(
        context,
        navigationShell,
      );
      if (shouldPop) navigator.pop();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: Scaffold(
        body: navigationShell,
        floatingActionButton: HomeFloatingButton(),
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        bottomNavigationBar: HomeBottomNavigationBar(
          navigationShell: navigationShell,
        ),
      ),
    );
  }
}
