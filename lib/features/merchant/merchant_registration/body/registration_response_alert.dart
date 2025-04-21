import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../merchant_dashboard/core/merchant_dashboard_route.dart'; // only for Icons and Colors

void submitForm(BuildContext cont, String name) async {
  showCupertinoDialog(
    context: cont,
    builder: (con) => CupertinoAlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.check_mark_circled_solid,
              color: Colors.green[600], size: 26),
          const SizedBox(width: 6),
          const Text('Success'),
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          children: [
            const Text(
              'Your merchant registration was successful!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome, $name.',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'You can now proceed to your dashboard and start setting up your store.',
              style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
            ),
          ],
        ),
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            if (Navigator.of(con).canPop()) Navigator.of(con).pop();

            // Navigate to dashboard
            cont.go(MerchantDashboardRoute.dashboard);
          },
          child: const Text('Go to Dashboard'),
        ),
      ],
    ),
  );
}
