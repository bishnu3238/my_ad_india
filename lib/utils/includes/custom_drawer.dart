// custom_drawer.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_ad/features/terms/core/terms_and_conditiaons_route.dart';
import 'package:pack/extensions/contextx.dart';
import 'package:provider/provider.dart';
import '../../features/profile/core/profile_navigator.dart';
import 'drawer_provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DrawerProvider(),
      child: _DrawerContent(),
    );
  }
}

class _DrawerContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final drawerProvider = Provider.of<DrawerProvider>(context);
    final screenSize = MediaQuery.of(context).size;
    final drawerWidth = screenSize.width * 0.85;

    return Drawer(
      width: drawerWidth,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(2),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildCloseButton(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProfileSection(context, drawerProvider),
                    const SizedBox(height: 16),
                    _buildQuickActionOptions(context),
                    const Divider(thickness: 1),
                    _buildBusinessOptions(context),
                    const Divider(thickness: 1),
                    _buildAppSettings(context, drawerProvider),
                    const Divider(thickness: 1),
                    _buildMoreInformation(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: const Icon(Icons.close, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, DrawerProvider provider) {
    return Consumer<DrawerProvider>(
      builder: (context, provider, _) {
        if (provider.isAuthenticated) {
          // Authenticated User View
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.green,
                  child: Text(
                    provider.user?.name.substring(0, 1).toUpperCase() ?? "S",
                    style: const TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.user?.name ?? 'Store Six',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      InkWell(
                        onTap: () => context.push(ProfileNavigator.profile),
                        // Navigate to profile screen
                        child: Text(
                          'View Activity',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.blue[700],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.penToSquare,
                    color: context.colorScheme.primary,
                  ),
                  onPressed: () => context.push(ProfileNavigator.editProfile),
                  // Edit profile
                ),
              ],
            ),
          );
        } else {
          // Guest User View
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi Guest!',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to unlock the full experience',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to login screen
                      Navigator.pop(context);
                      context.push('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildQuickActionOptions(BuildContext context) {
    return Consumer<DrawerProvider>(
      builder: (context, provider, _) {
        if (provider.isAuthenticated) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context,
                    icon: Icons.favorite_border,
                    label: 'Favourites',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/favorites');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    context,
                    icon: Icons.credit_card,
                    label: 'Transactions',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/transactions');
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blue[800]),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessOptions(BuildContext context) {
    return Column(
      children: [
        _buildDrawerItem(
          context,
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'FREE',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          title: 'List your Business for',
          trailing: const Text(
            'Free',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
          ),
          onTap: () {
            Navigator.pop(context);
            context.push('/list-business');
          },
        ),
        _buildDrawerItem(
          context,
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'AD',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
            ),
          ),
          title: 'Advertise & Grow your Business',
          onTap: () {
            Navigator.pop(context);
            context.push('/advertise');
          },
        ),
      ],
    );
  }

  Widget _buildAppSettings(BuildContext context, DrawerProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'App and User Setting',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        _buildLanguageSelector(context),
        _buildDrawerItem(
          context,
          icon: const Icon(Icons.settings, color: Colors.grey),
          title: 'Settings',
          onTap: () {
            Navigator.pop(context);
            context.go('/setting');
          },
        ),
        _buildDrawerItem(
          context,
          icon: const Icon(Icons.chat_bubble_outline, color: Colors.grey),
          title: 'App Feedback',
          onTap: () {
            Navigator.pop(context);
            context.push(TermsRoute.appSupport);
            // context.push('${TermsRoute.feedback}/0/0/${provider.user?.name}');
          },
        ),
        _buildDrawerItem(
          context,
          icon: const Icon(Icons.share, color: Colors.grey),
          title: 'Share App',
          onTap: () {
            // Share app functionality
          },
        ),
        _buildDrawerItem(
          context,
          icon: const Icon(Icons.headset_mic_outlined, color: Colors.grey),
          title: 'Customer Support',
          onTap: () {
            Navigator.pop(context);
            context.push(TermsRoute.appSupport);
          },
        ),
        Consumer<DrawerProvider>(
          builder: (context, provider, _) {
            if (provider.isAuthenticated) {
              return _buildDrawerItem(
                context,
                icon: const Icon(Icons.logout, color: Colors.grey),
                title: 'Logout',

                onTap: () async {
                  await provider.logout();
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Logged out successfully',
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              );
            } else {
              return _buildDrawerItem(
                context,
                icon: const Icon(Icons.login, color: Colors.grey),
                title: 'Login',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/login');
                },
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildLanguageOption(context, 'English', isSelected: true),
              _buildLanguageOption(context, 'हिंदी'),
              _buildLanguageOption(context, 'தமிழ்'),
              _buildLanguageOption(context, 'ಕನ್ನಡ'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String language, {
    bool isSelected = false,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: InkWell(
          onTap: () {
            // Change language functionality
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isSelected ? Colors.blue.shade50 : Colors.transparent,
            ),
            alignment: Alignment.center,
            child: Text(
              language,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreInformation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'More Information',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        _buildDrawerItem(
          context,
          icon: const Icon(Icons.policy_outlined, color: Colors.grey),
          title: 'Privacy Policy',
          onTap: () {
            Navigator.pop(context);
            context.push('/privacy-policy');
          },
        ),
        _buildDrawerItem(
          context,
          icon: const Icon(Icons.description_outlined, color: Colors.grey),
          title: 'Terms of Use',
          onTap: () {
            Navigator.pop(context);
            context.push('/terms');
          },
        ),
        _buildDrawerItem(
          context,
          icon: const Icon(Icons.people_outline, color: Colors.grey),
          title: 'Investor Relations',
          onTap: () {
            Navigator.pop(context);
            context.push('/investors');
          },
        ),
        _buildDrawerItem(
          context,
          icon: const Icon(Icons.lightbulb_outline, color: Colors.grey),
          title: 'What\'s New',
          onTap: () {
            Navigator.pop(context);
            context.push('/whats-new');
          },
        ),
        _buildDrawerItem(
          context,
          icon: const Icon(Icons.info_outline, color: Colors.grey),
          title: 'About Us',
          onTap: () {
            Navigator.pop(context);
            context.push('/about');
          },
        ),
      ],
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required Widget icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: icon,
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
      dense: true,
      visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
    );
  }
}
