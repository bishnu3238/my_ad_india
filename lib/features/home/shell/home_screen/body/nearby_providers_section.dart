import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_ad/core/constant/trasnlation_key.dart';
import 'package:my_ad/features/home/shell/home_screen/core/home_provider.dart';
// import 'package:my_ad/utils/translation_service/easy_localize.dart';
import 'package:pack/services/service.dart';
import 'package:pack/ui/widgets/loading/advance_shimmer_loading_ui.dart';
import 'package:provider/provider.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../ead_products/core/ead_product_navigator.dart';
import 'dart:developer' as dev;
import '../../../../../core/data/model/model.dart';
import 'package:go_router/go_router.dart';

class NearbyProvidersSection extends StatefulWidget {
  const NearbyProvidersSection({super.key});

  @override
  State<NearbyProvidersSection> createState() => _NearbyProvidersSectionState();
}

class _NearbyProvidersSectionState extends State<NearbyProvidersSection> {
  late Future<List<ProductModel>> fetchNearbyProviders;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    fetchNearbyProviders = context
        .read<HomeScreenProvider>()
        .fetchNearbyProviders(context);

    return Consumer<HomeScreenProvider>(
      builder: (context, homeViewModel, child) {
        return FutureBuilder<List<ProductModel>>(
          // initialData: const [],
          future: fetchNearbyProviders,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ListItemShimmer();
            } else if (snapshot.hasError) {
              return SizedBox(); //Center(child: Text('Error: ${snapshot.error}
            } else if (!snapshot.hasData ||
                homeViewModel.nearByProviders.isEmpty) {
              dev.log('Snapshow has data ${snapshot.hasData}');
              return const Center(child: Text('No nearby providers found.'));
            } else if (snapshot.data!.isEmpty &&
                homeViewModel.nearByProviders.isEmpty) {
              return SizedBox();
            } else {
              final providers = homeViewModel.nearByProviders!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        AutoSizeText(
                          context.tr(TranslationKey.nearbyProducts.key),
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        // TextButton(
                        //   onPressed: () {},
                        //   child: const Text('View Map'),
                        // ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: providers.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final provider = providers[index];
                        return _NearbyProviderCard(
                          onTap:
                              () =>
                                  _navigateToProductDetails(context, provider),
                          name: provider.merchant.username,
                          service: provider.serviceName,
                          distance: provider.address,
                          avatarUrl: provider.merchant.imgUrl,
                          // name: provider['name']!,
                          // service: provider['service']!,
                          // distance: provider['distance']!,
                          // avatarUrl: provider['avatar']!,
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  void _navigateToProductDetails(
    BuildContext context,
    ProductModel product,
  ) async {
    if (!await AuthCheckService.checkAuthAndShowPopupIfNeeded(context)) return;
    if (context.mounted) {
      EadProductRoute.goToEadProductDetails(context, product);
      // context.push(
      //   '${EadProductRoute.eadServices}/${product.id}/${ProductSearchBy.product.name}${EadProductRoute.eadServiceDetails}',
      //   extra: product,
      // );
    }
  }
}

class _NearbyProviderCard extends StatelessWidget {
  final String name;
  final String service;
  final String distance;
  final String avatarUrl;
  final VoidCallback onTap;

  const _NearbyProviderCard({
    required this.name,
    required this.service,
    required this.distance,
    required this.avatarUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(avatarUrl),
                radius: 26,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      service,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.blueGrey,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 13,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          distance,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
