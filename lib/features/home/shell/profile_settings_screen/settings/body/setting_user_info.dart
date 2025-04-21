import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pack/pack.dart';
import 'package:provider/provider.dart';

 import '../core/setting_view_model.dart';

class SettingUserInfo extends StatelessWidget {
  const SettingUserInfo({super.key});

  void _navigateToProfile(BuildContext context) {
/// TODO: navigator to profile page.
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileSettingsViewModel>(
      builder: (context, settingsViewModel, _) {
        return SliverToBoxAdapter(
          child: GestureDetector(
            onTap:
                settingsViewModel.isLoggedIn
                    ? () => _navigateToProfile(context)
                    : null,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Profile image
                  Hero(
                    tag: 'profile-image',
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.blue.shade700,
                          width: 2,
                        ),
                      ),
                      child: ImageView(
                        source: ImageSource.network,
                        path: settingsViewModel.user.profileImage!,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // User info
                  Expanded(
                    child:
                        settingsViewModel.isLoggedIn &&
                                !settingsViewModel.user.isEmpty
                            ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  settingsViewModel.user.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  settingsViewModel.user.email,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            )
                            : const Text(
                              'Guest User',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),

                  if (settingsViewModel.isLoggedIn)
                    Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
