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
      appBar: AppBar(
        title: const Text('My Services'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<MerchantServicesProvider>().refresh(),
          ),
        ],
      ),
      body: const _ServicesScreenBody(),
      floatingActionButton: Consumer<MerchantServicesProvider>(
        builder: (context, provider, _) {
          return provider.canAddMoreServices
              ? FloatingActionButton(
                onPressed:
                    () => context
                        .push(MerchantDashboardRoute.addService)
                        .then((_) => provider.refresh()),
                child: const Icon(Icons.add),
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
                Text(
                  'Error: ${provider.error?.message}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: service.refresh,
                  child: const Text('Retry'),
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
                const Text(
                  'You haven\'t added any services yet.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                if (service.canAddMoreServices)
                  ElevatedButton(
                    onPressed:
                        () =>
                            context.read<MerchantServicesProvider>().refresh(),
                    child: const Text('Add Your First Service'),
                  ),
                if (!service.canAddMoreServices)
                  const Text(
                    'Your plan doesn\'t allow adding services.',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => service.refresh(),
          child: ListView(
            // itemCount: 3,
            padding: const EdgeInsets.all(16),
            // itemBuilder:
            //     (BuildContext context, int index) =>
            children: [
              ServiceStatsCard(
                totalServices: provider.entity!.services.length,
                remainingServices:
                    provider.entity!.planAccess.remainingServices,
                remainingUpdates: provider.entity!.planAccess.remainingUpdates,
                validUntil: provider.entity!.planAccess.validUntil!,
              ),
              const SizedBox(height: 16),
              ServiceListView(services: provider.entity!.services),
            ],
          ),
        );
      },
    );
  }
}
