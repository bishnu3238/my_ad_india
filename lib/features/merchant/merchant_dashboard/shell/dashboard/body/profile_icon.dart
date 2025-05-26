import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_ad/features/merchant/merchant_dashboard/core/merchant_dashboard_route.dart';
import 'package:my_ad/features/merchant/merchant_dashboard/shell/merchant_add_service/core/merchant_add_service_route.dart';
import 'package:pack/pack.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/domain/data_store/merchant_dashboard_store.dart';
import '../../../../../../utils/widgets/svg_icon_widget.dart';
import '../../../core/merchant_dashboard_shell_provider.dart';
import '../../merchant_settings/core/merchant_settings_route.dart';

class ProfileIcon extends StatelessWidget {
  const ProfileIcon({super.key});

  void _showProfileMenu(BuildContext context, String username) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    final theme = Theme.of(context).colorScheme;

    showMenu(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      items: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: Container(
            width: 280,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.primary.withValues(alpha: 0.1),
                      radius: 24,
                      child: SvgIconWidget(
                        iconPath: SvgIcons.profileIcon,
                        height: 28,
                        package: 'pack',
                        colorFilter: ColorFilter.mode(
                          theme.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Merchant Account",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to profile edit page
                    context
                        .read<MerchantDashboardShellProvider>()
                        .shell
                        .goBranch(4);
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide(color: theme.primary),
                  ),
                  child: Text(
                    "Edit Profile",
                    style: TextStyle(color: theme.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (context.read<MerchantDashboardStore>().entity!.services.isEmpty)
          _buildMenuItem(
            context,
            "Add New Service",
            Icons.add_circle_outline,
            () {
              // Handle add new service
              Navigator.pop(context);
              context.push(MerchantDashboardRoute.addService);
            },
          ),
        _buildMenuItem(context, "Settings", Icons.settings_outlined, () {
          // Handle settings
          Navigator.pop(context);
          context.push(MerchantSettingsRoute.settings);
        }),
        _buildMenuItem(
          context,
          "Notifications",
          Icons.notifications_outlined,
          () {
            // Handle notifications
            Navigator.pop(context);
          },
        ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () {
                // Handle logout

                // Navigator.pop(context);
                context.read<MerchantDashboardShellProvider>().onLogout(
                  context,
                );
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              minLeadingWidth: 24,
            ),
          ),
        ),
      ],
    );
  }

  PopupMenuItem _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        minLeadingWidth: 24,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Consumer<MerchantDashboardStore>(
      builder: (context, store, _) {
        final username = store.entity?.merchantData.merchant.username ?? 'User';
        final profilePic =
            store.entity?.merchantData.merchant.companyLogo!.trim();
        dev.log(
          'Profile Icon: ${store.entity?.merchantData.merchant.companyLogo}',
        );
        return InkWell(
          onTap: () => _showProfileMenu(context, username),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            margin: EdgeInsets.only(left: 16),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16 / 2),
            child: Row(
              children: [
                if (profilePic == null || profilePic == '') ...[
                  SvgIconWidget(
                    iconPath: SvgIcons.profileIcon,
                    height: 20,
                    package: 'pack',
                    colorFilter: ColorFilter.mode(
                      theme.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ] else if (profilePic.isNotEmpty &&
                    profilePic.contains('http://'))
                  ImageView(
                    source: ImageSource.network,
                    path: profilePic,
                    height: 20,
                    width: 20,
                  ),
                Icon(Icons.keyboard_arrow_down, color: theme.primary, size: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
