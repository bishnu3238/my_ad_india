import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:my_ad/core/domain/data_store/data_store.dart';
import 'package:my_ad/utils/widgets/header_section.dart';
import 'package:pack/pack.dart';
import 'package:provider/provider.dart';
import '../../core/merchant_dashboard_shell_provider.dart';
import 'body/add_merchant_sevice_card.dart';
import 'body/header.dart';
import 'body/merchant_service_section.dart';
import 'body/recent_inquiries.dart';
import 'body/upgrade_plan_card.dart';
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
    final store = context.read<MerchantDashboardStore>();
    final merchantData = store.entity?.merchantData;

    final categoryStore = context.read<CategoryStore>();
    final serviceStore = context.read<ServiceStore>();
    final selectedCategory =
        merchantData?.serviceDetails.categoryId != null
            ? categoryStore.getById(merchantData!.serviceDetails.categoryId)
            : null;
    final selectedService =
        merchantData?.serviceDetails.serviceId != null
            ? serviceStore.getById(merchantData!.serviceDetails.serviceId)
            : null;

    return Consumer<MerchantDashboardShellProvider>(
      builder: (context, shellProvider, _) {
        return Consumer<DashboardProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return BuildShimmerLoading();
            }
            return OverlayLoader(
              isLoading: provider.isLoading,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFe0eafc), Color(0xFFcfdef3)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: RefreshIndicator.adaptive(
                    onRefresh:
                        () => context.read<DashboardProvider>().initialFetch(),
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      slivers: [
                        SliverToBoxAdapter(child: Header()),
                        // Upgrade Plan Card
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: const UpgradePlanCard(),
                          ),
                        ),

                        // Dashboard Cards (Services, Customer, etc.)
                        if (store.entity!.services.isEmpty) ...[
                          AddMerchantServiceCard(
                            selectedCategory: selectedCategory,
                            selectedService: selectedService,
                          ),
                        ] else ...[
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: 15.symmetricHV(8),
                              child: const MerchantServicesPage(),
                            ),
                          ),

                          // Recent Inquiry
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: const RecentInquiry(),
                            ),
                          ),
                          // Bottom Padding
                          const SliverToBoxAdapter(child: SizedBox(height: 40)),
                        ],
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
