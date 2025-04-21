import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppNavigationHandler {
  // Singleton instance
  static final AppNavigationHandler _instance = AppNavigationHandler._internal();
  factory AppNavigationHandler() => _instance;
  AppNavigationHandler._internal();

  // Global navigation key
  final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

  // Navigation method with error handling
  void navigateTo(BuildContext context, String path, {Object? extra}) {
    try {
      context.go(path, extra: extra);
    } catch (e) {
      _handleNavigationError(context, e);
    }
  }

  // Named navigation method
  void navigateNamed(
      BuildContext context,
      String name, {
        Map<String, String> pathParameters = const {},
        Map<String, String> queryParameters = const {},
        Object? extra,
      }) {
    try {
      context.goNamed(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        extra: extra,
      );
    } catch (e) {
      _handleNavigationError(context, e);
    }
  }

  // Safe pop method
  void pop(BuildContext context) {
    try {
      if (Navigator.of(context).canPop()) {
        context.pop();
      }
    } catch (e) {
      _handleNavigationError(context, e);
    }
  }

  // Error handling method
  void _handleNavigationError(BuildContext context, Object error) {
    // Log the error (you can replace with your preferred logging)
    print('Navigation Error: $error');

    // Show user-friendly error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Unable to navigate. Please try again.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Prevent multiple navigation calls
  void safeNavigate(BuildContext context, VoidCallback navigationCallback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigationCallback();
    });
  }
}
