import 'dart:developer' as dev;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_ad/core/domain/data_store/data_store.dart';
import 'package:my_ad/features/merchant/merchant_dashboard/core/merchant_dashboard_route.dart';
import 'package:my_ad/features/merchant/subscription/core/subscription_plan_provider.dart';
import 'package:my_ad/utils/widgets/svg_icon_widget.dart';
import 'package:pack/pack.dart';
import 'package:provider/provider.dart';

class UpgradePlanCard extends StatelessWidget {
  const UpgradePlanCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Consumer<MerchantDashboardStore>(
      builder: (context, store, _) {
        final plan = store.entity?.planAccess.planModel;
        final isPlanExpired = !store.entity!.planAccess.isSubscriptionValid();
        final currentSubscription = store.entity!.merchantData.subscription;
        dev.log(
          'plan status: ${store.isLoading} +++++++ ${currentSubscription.isActive} ${currentSubscription.planStatus} ${currentSubscription.status}',
        );
        final merchantPlan = store.entity!.planAccess;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    isPlanExpired
                        ? [theme.error.withValues(alpha: 0.7), theme.error]
                        : [theme.primary.withValues(alpha: 0.7), theme.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgIconWidget(
                      iconPath:
                          isPlanExpired
                              ? SvgIcons.loadingIcon
                              : SvgIcons.newCardIcon,
                      colorFilter: ColorFilter.mode(
                        theme.surface,
                        BlendMode.srcIn,
                      ),
                    ),

                    const SizedBox(width: 10),
                    const Text(
                      'Subscription Plan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Spacer(),
                    SvgIconWidget(
                      iconPath: SvgIcons.arrowRightSquareIcon,
                      onTap: () {
                        context.push(MerchantDashboardRoute.subscription);
                      },
                      colorFilter: ColorFilter.mode(
                        theme.surface,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (currentSubscription.isActive) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ImageView(
                                  source: ImageSource.network,
                                  path: plan?.fullImageUrl,
                                  width: 30,
                                  height: 30,
                                  shape: ImageShape.circle,
                                ),
                                const SizedBox(width: 10),
                                AutoSizeText(
                                  currentSubscription.planName,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: theme.surface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            AutoSizeText.rich(
                              TextSpan(
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: theme.surface,
                                ),
                                text: '${Currency.rupeeSymbol}${plan!.offer}',
                                children: [
                                  TextSpan(
                                    text: ' ${plan.planRate.toInt()}',
                                    style: GoogleFonts.rubikPixels(
                                      fontSize: 18,
                                      decoration: TextDecoration.lineThrough,
                                      color: theme.inversePrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Text(
                            //   '${Currency.rupeeSymbol}${plan!.offer} ${plan.planRate.toInt()}',
                            //   style: GoogleFonts.rubikPixels(
                            //     fontSize: 18,
                            //     color: theme.inversePrimary,
                            //   ),
                            // ),
                            Text(
                              currentSubscription.endDate.toMediumDate(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      VerticalDivider(color: theme.surface, thickness: 2),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Plan',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.surface,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Valid for ${plan.validity} Days',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            AutoSizeText(
                              '${currentSubscription.endDate.difference(DateTime.now()).inDays} Days Left',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Card(
                    margin: edgeInsets,
                    color:
                        merchantPlan.remainingServices != 0
                            ? theme.primary
                            : theme.onErrorContainer,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                      child: AutoSizeText(
                        'Service available ${merchantPlan.remainingServices}/${plan.numberOfServices}',
                        style: GoogleFonts.padauk(color: theme.surface),
                      ),
                    ),
                  ),
                ] else ...[
                  const Text(
                    'No active subscription',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
                const SizedBox(height: 16),
                if (isPlanExpired)
                  const Text(
                    'Your subscription has expired! Upgrade now to continue using all features.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
