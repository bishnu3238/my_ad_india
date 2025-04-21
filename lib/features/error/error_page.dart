import 'package:flutter/material.dart';

import '../../utils/handler/app_navigation_handler.dart';

class ErrorPage extends StatelessWidget {
  final String title;
  final String errorMessage;
  final Widget? child;
  final VoidCallback? onRetry;
  final VoidCallback? onBack;

  const ErrorPage({
    super.key,
    required this.title,
    required this.errorMessage,
    this.child,
    this.onBack,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 100),
          SizedBox(height: 20),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...[
            SizedBox(height: 10),
            Text(
              errorMessage.toString(),
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
          SizedBox(height: 20),
          ElevatedButton(
            onPressed:
                onRetry ??
                () => AppNavigationHandler().navigateTo(context, '/home'),
            child: onRetry != null ? Text('Retry') : Text('Return to Home'),
          ),
        ],
      ),
    );
  }
}
