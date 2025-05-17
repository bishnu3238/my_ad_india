import 'package:flutter/material.dart';
import 'package:my_ad/features/chat_feature/widgets/chat_widgets.dart';
import 'package:pack/extensions/numx.dart';
import 'package:pack/pack.dart';
import 'package:provider/provider.dart';
import 'merchant_profile_provider.dart';
import 'profile_header.dart';
import 'profile_option_tile.dart';
import 'profile_logout_button.dart';

class MerchantProfileScreen extends StatelessWidget {
  const MerchantProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MerchantProfileProvider()..loadProfile(),
      child: Consumer<MerchantProfileProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (provider.error != null) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      provider.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: provider.loadProfile,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          final profile = provider.profile!;
          return Scaffold(
            extendBodyBehindAppBar: true,

            body: OverlayLoader(
              isLoading: provider.isLoading,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFe0eafc), Color(0xFFcfdef3)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SingleChildScrollView(
                  padding: 20.symmetricVH(12),
                  child: Column(
                    children: [
                      ProfileHeader(
                        profile: profile,
                        onEdit: () => provider.onEditProfile(context),
                      ),
                      const SizedBox(height: 28),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            ProfileOptionTile(
                              title: 'Account Settings',
                              icon: Icons.settings,
                              onTap: provider.onAccountSettings,
                            ),
                            ProfileOptionTile(
                              title: 'Business Information',
                              icon: Icons.business,
                              onTap: provider.onBusinessInfo,
                            ),
                            ProfileOptionTile(
                              title: 'Subscription & Billing',
                              icon: Icons.subscriptions,
                              onTap: provider.onSubscription,
                            ),
                            ProfileOptionTile(
                              title: 'Notifications',
                              icon: Icons.notifications,
                              onTap: () => provider.onNotifications(context),
                            ),
                            ProfileOptionTile(
                              title: 'Help & Support',
                              icon: Icons.help,
                              onTap: () => provider.onHelp(context),
                            ),
                            ProfileOptionTile(
                              title: 'Privacy & Security',
                              icon: Icons.security,
                              onTap: () => provider.onPrivacy(context),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      ProfileLogoutButton(
                        onLogout: () => provider.onLogout(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
