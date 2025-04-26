import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:my_ad/routes/auth/auth_routes.dart';
import 'package:pack/auth/custom_auth.dart';
import 'package:provider/provider.dart';
import '../../utils/widgets/auth_popup.dart';
import '../data/model/model.dart';

class AuthCheckService {
  /// Shows authentication popup if user is not logged in
  /// Returns true if user is authenticated, false otherwise
  static Future<bool> checkAuthAndShowPopupIfNeeded(
    BuildContext context, {
    String title = 'Authentication Required',
    String message = 'Please login or create an account to access this service',
  }) async {
    // Get the auth provider
    final authProvider = context.read<AuthProviderModel<UserModel>>();

    // Check if already authenticated
    if (authProvider.isAuthenticated) {
      return true;
    }

    // User is not authenticated, show popup
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AuthRequiredPopup(
            title: title,
            message: message,
            onLogin: () {
              // Close dialog and navigate to login
              Navigator.pop(context, false);
              context.push(AuthRoutes.login);
            },
            onSignup: () {
              // Close dialog and navigate to signup
              Navigator.pop(context, false);
              Navigator.pushNamed(context, '/signup');
            },
            onCancel: () {
              // User cancelled, return to previous screen
              Navigator.pop(context, false);
              Navigator.pop(context);
            },
          ),
    );

    // Check authentication status again (in case user just logged in)
    await authProvider.initialize();
    return authProvider.isAuthenticated;
  }

  // Show HapticFeedback and display a quick toast message
  static void showAuthError(BuildContext context, String message) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
