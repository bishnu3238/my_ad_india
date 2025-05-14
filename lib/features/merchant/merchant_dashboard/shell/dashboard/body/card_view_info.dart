import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pack/extensions/contextx.dart';
import 'package:pack/extensions/stringx.dart';
import 'package:pack/resources/svg_icons.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/data/model/merchant/merchant.dart';
import '../../../../../../core/domain/data_store/data_store.dart';
import '../../../../../../utils/widgets/svg_icon_widget.dart';
import '../../../core/merchant_dashboard_shell_provider.dart';

class CardViewInfo extends StatelessWidget {
  final MerchantServiceModel service;

  const CardViewInfo({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final isApproved = service.businessPartnerApprove == 1;
    final isActive = service.status == 1;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Top Row with Icon and Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: theme.primaryContainer.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SvgIconWidget(
                    iconPath: SvgIcons.product,
                    colorFilter: ColorFilter.mode(
                      theme.primary,
                      BlendMode.srcIn,
                    ),
                    package: 'pack',
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: context.primaryColor),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        // Add your navigation logic here
                        break;
                      case 'delete':
                        // Show confirmation before deleting
                        break;
                      case 'view':
                        // Navigate to service detail
                        break;
                    }
                  },
                  itemBuilder:
                      (BuildContext context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Text('View Details'),
                        ),
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// Service Title
            Text(
              service.serviceName.capitalized,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            /// Status Labels
            Row(
              children: [
                // _StatusChip(
                //   label: isActive ? 'Active' : 'Inactive',
                //   color: isActive ? theme.primary : theme.error,
                // ),
                // const SizedBox(width: 8),
                _StatusChip(
                  label: isApproved ? 'Approved' : 'Pending Approval',
                  color: isApproved ? Colors.green : Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// Other Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AutoSizeText.rich(
                  TextSpan(
                    text: '200 ',
                    style: TextStyle(
                      color: context.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    children: const [
                      TextSpan(
                        text: 'inquiries',
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: theme.secondary),
                    const SizedBox(width: 4),
                    Text(
                      service.cityName,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 10),
    );
  }
}
