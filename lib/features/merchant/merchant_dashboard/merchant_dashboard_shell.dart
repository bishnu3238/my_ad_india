import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';
import '../../../core/domain/data_store/data_store.dart';
import '../../../utils/handler/back_gesture_handler.dart';
import '../../home/core/home_navigator.dart';
import '../../../core/data/model/model.dart';
import 'body/bottom_navigation_bar.dart';
import 'body/merchant_app_drawer.dart';

class MerchantDashboardShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MerchantDashboardShell({super.key, required this.navigationShell});

  Widget _buildChatButton(BuildContext context) {
    return Consumer<MerchantDashboardStore>(
      builder: (context, authProvider, _) {
        return ElevatedButton.icon(
          onPressed: () {
            // Check if user is logged in
            if (!authProvider.entity!.isAuthenticated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please login to access chat')),
              );
              return;
            }

            // Get merchant ID and name from auth provider
            final merchantId = authProvider.entity!.id.toString();
            final merchantName =
                authProvider.entity!.merchantData.merchant.username;

            /// TODO:  Navigate to merchant chat screen
          },
          icon: const Icon(Icons.chat),
          label: const Text('Messages & Inquiries'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        );
      },
    );
  }

  onPopInvokedWithResult(didPop, result, BuildContext context) async {
    var navigator = Navigator.of(context);
    if (didPop) return;
    final shouldPop = await BackGestureHandler.handleMerchant(
      context,
      navigationShell,
    );
    if (shouldPop && context.mounted) context.go(HomeRoute.home);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult:
          (didPop, result) => onPopInvokedWithResult(
            didPop,
            result,
            context,
          ), // (didPop, result) async {
      // if (didPop) return;
      // final shouldPop = await BackGestureHandler.handleMerchant(context);
      // if (shouldPop && context.mounted) context.go(HomeRoute.home);
      // },
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
