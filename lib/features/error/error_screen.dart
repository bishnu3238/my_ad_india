import 'package:flutter/material.dart';

import '../../utils/handler/app_navigation_handler.dart';

class ErrorScreen extends StatelessWidget {
  final Exception? error;

  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Navigation Error'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 100,
            ),
            SizedBox(height: 20),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (error != null) ...[
              SizedBox(height: 10),
              Text(
                error.toString(),
                style: TextStyle(
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => AppNavigationHandler().navigateTo(context, '/home'),
              child: Text('Return to Home'),
            ),
          ],
        ),
      ),
    );
  }
}