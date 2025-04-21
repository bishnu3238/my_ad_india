import 'package:flutter/material.dart';
import 'package:pack/pack.dart';
import 'package:provider/provider.dart';

import '../../core/merchant_dashboard_shell_provider.dart';
import 'body/header.dart';
import 'body/my_fields.dart';
import 'body/recent_files.dart';
import 'body/upgrade_plan_card.dart';
import '../../../subscription/core/subscription_plan_provider.dart';
import 'body/dashboard_card_items.dart';
import 'core/merchant_dashboard_provider.dart';

class MerchantDashboardHome extends StatefulWidget {
  const MerchantDashboardHome({super.key});

  @override
  State<MerchantDashboardHome> createState() => _MerchantDashboardHomeState();
}

class _MerchantDashboardHomeState extends State<MerchantDashboardHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().initialFetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantDashboardShellProvider>(
      builder: (context, provider, _) {
        return Consumer<DashboardProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return BuildShimmerLoading();
            }
            return OverlayLoader(
              isLoading: provider.isLoading,
              child: SafeArea(
                child: RefreshIndicator(
                  onRefresh:
                      () => context.read<DashboardProvider>().initialFetch(),
                  child: SingleChildScrollView(
                    primary: false,
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Header(),
                        SizedBox(height: 16),
                        const UpgradePlanCard(),
                        SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
                                children: [
                                  const MyServices(),
                                  SizedBox(height: 16),
                                  const RecentInquiry(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
