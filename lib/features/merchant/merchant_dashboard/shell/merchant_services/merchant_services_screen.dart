import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_ad/core/domain/data_store/data_store.dart';
import 'package:my_ad/core/injector/dependency_injection.dart';
import 'package:my_ad/features/merchant/merchant_dashboard/shell/merchant_add_service/merchant_add_service_screen.dart';
import 'package:my_ad/features/merchant/merchant_dashboard/shell/merchant_services/core/merchant_services_provider.dart';
import 'package:provider/provider.dart';

import '../../core/merchant_dashboard_route.dart';
import 'body/service_list_view.dart';
import 'body/service_stats_card.dart';

class MerchantServicesScreen extends StatelessWidget {
  const MerchantServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text('My Services'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<MerchantServicesProvider>().refresh(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: const _ServicesScreenBody(),
      floatingActionButton: Consumer<MerchantServicesProvider>(
        builder: (context, provider, _) {
          return provider.canAddMoreServices
              ? FloatingActionButton.extended(
                  onPressed: () => context
                      .push(MerchantDashboardRoute.addService)
                      .then((_) => provider.refresh()),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Service'),
                  backgroundColor: Colors.blueAccent,
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ServicesScreenBody extends StatelessWidget {
  const _ServicesScreenBody();

  @override
  Widget build(BuildContext context) {
    return Consumer2<MerchantDashboardStore, MerchantServicesProvider>(
      builder: (context, provider, service, _) {
        dev.log(
          'MerchantServicesScreen - build ${provider.entity!.services.length}',
        );

        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.isError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Error: ${provider.error?.message}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: service.refresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          );
        }

        if (provider.entity!.services.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline, size: 48, color: Colors.blueGrey),
                const SizedBox(height: 12),
                const Text(
                  'You haven\'t added any services yet.',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                if (service.canAddMoreServices)
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.read<MerchantServicesProvider>().refresh(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Your First Service'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                  ),
                if (!service.canAddMoreServices)
                  const Text(
                    'Your plan doesn\'t allow adding services.',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                  ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24 + kToolbarHeight, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ServiceStatsCard(
                  totalServices: provider.entity!.services.length,
                  remainingServices: provider.entity!.planAccess.remainingServices,
                  remainingUpdates: provider.entity!.planAccess.remainingUpdates,
                  validUntil: provider.entity!.planAccess.validUntil!,
                ),
                const SizedBox(height: 24),
                ServiceListView(services: provider.entity!.services),
              ],
            ),
          ),
        );
      },
    );
  }
}
