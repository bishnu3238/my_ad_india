import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:my_ad/core/domain/data_store/data_store.dart';
import 'package:pack/ui/ui.dart';
import 'package:provider/provider.dart';
import 'package:pack/services/service.dart';
import '../../../../../core/data/model/product/service_model.dart';
import '../../../../ead_products/core/ead_product_navigator.dart';
import '../core/home_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../all_services/core/all_services_route.dart';

class HomeServicesSection extends StatelessWidget {
  const HomeServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Consumer2<ServiceStore, HomeScreenProvider>(
      builder: (context, serviceStore, homeProvider, _) {
        final services =
            serviceStore.items
                .where(
                  (e) =>
                      '${e.categoryId}' == homeProvider.state.selectedCategory,
                )
                .toList();

        final itemCount = services.length > 20 ? 21 : services.length;

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              final isViewAll = services.length > 20 && index == 20;
              final service = isViewAll ? null : services[index];

              return GestureDetector(
                onTap: () {
                  if (isViewAll) {
                    context.push(
                      '${AllServicesRoute.allServices}/${homeProvider.state.selectedCategory}/${ShowServicesBy.category.name}',
                    );
                  } else {
                    context.push(
                      '${EadProductRoute.eadServices}/${service!.id}/${ProductSearchBy.service.name}',
                    );
                  }
                },
                child: ServiceCard(
                  service: service,
                  isViewAllCard: isViewAll,
                  width: width,
                ),
              );
            }, childCount: itemCount),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
          ),
        );
      },
    );
  }
}

class ServiceCard extends StatelessWidget {
  final ServiceModel? service;
  final bool isViewAllCard;
  final double width;

  const ServiceCard({
    super.key,
    this.service,
    required this.isViewAllCard,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isViewAllCard ? _buildViewAll() : _buildService(context),
    );
  }

  Widget _buildService(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ImageView(
              path: service!.fullImageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              source: ImageSource.network,
              placeholder: Container(
                color: Colors.grey[200],
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          flex: 1,
          child: Text(
            service!.serviceName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: width * 0.028,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewAll() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.grid_view_rounded, size: 36, color: Colors.blue),
        const SizedBox(height: 12),
        Text(
          "View All",
          style: TextStyle(
            fontSize: width * 0.03,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Services",
          style: TextStyle(
            fontSize: width * 0.025,
            color: Colors.blue.shade600,
          ),
        ),
      ],
    );
  }
}
