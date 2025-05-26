import 'package:flutter/material.dart';
import 'package:my_ad/core/injector/dependency_injection.dart';
import 'package:my_ad/core/services/product_service.dart';
import 'package:my_ad/features/merchant/merchant_dashboard/shell/dashboard/core/merchant_dashboard_provider.dart';
import 'package:pack/pack.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/domain/data_store/merchant_dashboard_store.dart';
import '../../../../customer_inquiries/core/customer_inquiry_route.dart';

class RecentInquiry extends StatelessWidget {
  const RecentInquiry({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: theme.secondaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and View All button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Inquiry",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton.icon(
                onPressed: () {
                  // final merchantID =
                  //     context.read<MerchantDashboardStore>().merchantId;
                  // DependencyInjector.get<ProductService>().getInquiry(
                  //   merchantID.toString(),
                  // );
                  CustomerInquiryRoute.openInquiry(context);
                },
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: theme.primary,
                ),
                label: Text(
                  "View All",
                  style: TextStyle(
                    color: theme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Data table
          Consumer<DashboardProvider>(
            builder: (context, provider, _) {
              // Show empty state if no visits
              if (provider.visits.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: theme.onSecondaryContainer.withOpacity(0.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "No recent inquiries",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: theme.onSecondaryContainer.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.outline.withOpacity(0.2)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: DataTable(
                    columnSpacing: 8,
                    horizontalMargin: 9,
                    headingRowHeight: 40,
                    dataRowMinHeight: 56, // Increased minimum height
                    dataRowMaxHeight: 56, // Increased maximum height
                    headingRowColor: MaterialStateProperty.all(
                      theme.surfaceVariant.withOpacity(0.5),
                    ),
                    columns: [
                      DataColumn(
                        label: Text(
                          "Customer",
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Date",
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Message",
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                    rows: List.generate(
                      provider.visits.length > 5
                          ? 5
                          : provider.visits.length, // Show max 5 items
                      (index) => DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: theme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: 16,
                                    color: theme.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: SizedBox(
                                    height: 40, // Fixed height container
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize:
                                          MainAxisSize
                                              .min, // Important: minimize main axis size
                                      children: [
                                        Flexible(
                                          child: Text(
                                            provider
                                                .visits[index]
                                                .customer
                                                .username,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        if (provider
                                            .visits[index]
                                            .customer
                                            .email
                                            .isNotEmpty)
                                          Flexible(
                                            child: Text(
                                              provider
                                                  .visits[index]
                                                  .customer
                                                  .email,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall?.copyWith(
                                                color: theme.onSurface
                                                    .withOpacity(0.6),
                                                fontSize:
                                                    11, // Slightly smaller font
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              height: 40, // Fixed height container
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize:
                                    MainAxisSize
                                        .min, // Important: minimize main axis size
                                children: [
                                  Flexible(
                                    child: Text(
                                      provider.visits[index].dated
                                          .toDateTime()!
                                          .toDMY,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      _getTimeAgo(
                                        provider.visits[index].dated
                                            .toDateTime()!,
                                      ),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(
                                        color: theme.onSurface.withOpacity(0.5),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              constraints: const BoxConstraints(maxWidth: 200),
                              height: 40, // Fixed height container
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize:
                                    MainAxisSize
                                        .min, // Important: minimize main axis size
                                children: [
                                  Flexible(
                                    child: Text(
                                      provider.visits[index].message,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getContactTypeColor(
                                          provider.visits[index].contactType,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        provider.visits[index].contactType
                                            .toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: _getContactTypeColor(
                                            provider.visits[index].contactType,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  Color _getContactTypeColor(String contactType) {
    switch (contactType.toLowerCase()) {
      case 'phone':
        return Colors.blue;
      case 'email':
        return Colors.green;
      case 'chat':
        return Colors.purple;
      case 'whatsapp':
        return Colors.green;
      case 'sms':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
