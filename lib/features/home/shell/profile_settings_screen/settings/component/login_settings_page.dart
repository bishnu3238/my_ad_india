import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_ad/features/settings/core/settins_navigator.dart';
// import '../../../../../../utils/translation_service/prebuilt_language_selector.dart';
import '../../../../../../utils/widgets/svg_icon_widget.dart';
import 'package:pack/pack.dart';
import '../../../../../../core/data/model/model.dart';
import 'package:go_router/go_router.dart';
import '../../../../../favorites/core/favorites_route.dart';
import '../../../../../profile/core/profile_navigator.dart';
import '../../../../../refer_earn/core/refer_earn_route.dart';
import '../body/settings_items.dart';
import '../core/setting_view_model.dart';
import 'package:pack/auth/custom_auth.dart';
import 'package:provider/provider.dart';

class LoggedInSettingsPage extends StatelessWidget {
  final UserModel user;

  const LoggedInSettingsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        backgroundColor: Color(0xFF071667),
        foregroundColor: Colors.white,

        actions: [
          Padding(
            padding: 20.symmetricHV(0),
            child: SvgIconWidget(
              onTap: () {},
              width: 25,
              height: 25,
              iconPath: SvgIcons.notificationIcon,
              colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Profile header section
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF071667), Color(0xFF2E46DA)],
              ),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          user.profileImage != null &&
                                  user.profileImage!.isNotEmpty
                              ? NetworkImage(user.profileImage!)
                              : null,
                      child:
                          user.profileImage == null ||
                                  user.profileImage!.isEmpty
                              ? Text(
                                user.name.isNotEmpty == true
                                    ? user.name.substring(0, 1).toUpperCase()
                                    : "U",
                                style: const TextStyle(
                                  fontSize: 30,
                                  color: Colors.white,
                                ),
                              )
                              : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          // Settings options
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 8),

                  _buildSettingsTile(
                    context,
                    icon: FontAwesomeIcons.penToSquare,
                    title: 'Edit Profile',
                    onTap: () => context.push(ProfileNavigator.editProfile),
                  ),

                  _buildSettingsTile(
                    context,
                    icon: Icons.wallet_giftcard_outlined,
                    title: 'Refer & Earn',
                    onTap: () => context.push(ReferEarnRoute.referAndEarn),
                  ),
                  // _buildSettingsTile(
                  //   context,
                  //   icon: Icons.local_activity_outlined,
                  //   title: 'Activities',
                  //   onTap: () => context.push('/activities'),
                  // ),
                  const Divider(),
                  _buildSettingsTile(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () => context.push(SettingNavigator.appSettings),
                  ),
                  // _buildSettingsTile(
                  //   context,
                  //   icon: Icons.translate,
                  //   title: 'Language',
                  //   onTap: () => context.push(LanguageNavigator.languagePath),
                  // ),
                  // _buildSettingsTile(
                  //   context,
                  //   icon: Icons.trending_up_outlined,
                  //   title: 'Level',
                  //   onTap: () => context.push('/level'),
                  // ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.favorite_border_outlined,
                    title: 'Favorites',
                    onTap: () => FavoritesRoute.openPage(context),
                  ),

                  const Divider(),
                  BuildSettingItems(
                    icon: Icons.logout_outlined,
                    title: 'Logout',
                    onTap: () {
                      context.read<ProfileSettingsViewModel>().logout();
                      // _showLogoutDialog(context)
                    },
                    delay: 0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  // Navigator.pop(context);
                  //
                  // context.read<SettingsViewModel>().logout();
                  Navigator.pop(context);
                  final authProvider =
                      Provider.of<AuthProviderModel<UserModel>>(
                        context,
                        listen: false,
                      );
                  final success = await authProvider.logout();
                  if (success) {
                    context.go('/login');
                  }
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
