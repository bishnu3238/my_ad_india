import 'package:flutter/material.dart';
 import 'package:go_router/go_router.dart';
import '../../../../../../routes/auth/auth_routes.dart';
 import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

 import '../body/setting_appbar.dart';
import '../body/settings_items.dart';
import '../core/setting_view_model.dart';

class LoggedOutSettingsPage extends StatefulWidget {
  const LoggedOutSettingsPage({super.key});

  @override
  State<LoggedOutSettingsPage> createState() => _LoggedOutSettingsPageState();
}

class _LoggedOutSettingsPageState extends State<LoggedOutSettingsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Load settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsViewModel = Provider.of<ProfileSettingsViewModel>(
        context,
        listen: false,
      );

      Future.wait([
        settingsViewModel.loadSettings(),
      ]).then((_) => _animationController.forward());
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SettingAppBar(label: 'Settings'),
      body: Consumer<ProfileSettingsViewModel>(
        builder: (context, settingsViewModel, _) {
          return ListView(
            children: [
              buildHeader(label: 'Accounts'),
              buildSettingItem(
                icon: FontAwesomeIcons.arrowRightFromBracket,
                title: 'Login',
                onTap: () => context.push(AuthRoutes.login),
                isLoading: settingsViewModel.state == SettingsState.loading,
                slideAnimation: _slideAnimation,
                delay: 0,
                controller: _animationController,
              ),
              buildSettingItem(
                icon: FontAwesomeIcons.arrowRightToBracket,
                title: 'Sign up',
                onTap: () => context.push(AuthRoutes.register),
                isLoading: settingsViewModel.state == SettingsState.loading,
                slideAnimation: _slideAnimation,
                delay: 0,
                controller: _animationController,
              ),

              const Divider(),

              buildHeader(label: 'Preferences'),
              buildSettingItemWithSwitch(
                icon: Icons.notifications,
                title: 'Notifications',
                value: settingsViewModel.notificationsEnabled,
                onChanged:
                    (value) => settingsViewModel.toggleNotifications(value),
                slideAnimation: _slideAnimation,
                delay: 1,
                controller: _animationController,
              ),

              // Theme
              buildSettingItemWithSwitch(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                value: settingsViewModel.isDarkMode,
                onChanged: (value) => settingsViewModel.setThemeMode(value),
                slideAnimation: _slideAnimation,
                delay: 2,
                controller: _animationController,
              ),

              // Language
              buildSettingItem(
                icon: Icons.language,
                title: 'Language',
                subtitle: 'English',
                onTap: () => showLanguageDialog(settingsViewModel, context),
                slideAnimation: _slideAnimation,
                delay: 3,
                controller: _animationController,
              ),

              const Divider(),

              buildHeader(
                label: 'Privacy',
                onTap: () => context.push('/privacy'),
              ),

              buildSettingItem(
                icon: FontAwesomeIcons.magnifyingGlass,
                title: 'Search History',
                onTap: () => context.push('/search_history'),
                slideAnimation: _slideAnimation,
                delay: 5,
                controller: _animationController,
              ),

              buildSettingItem(
                icon: FontAwesomeIcons.info,
                title: 'About Us',
                onTap: () => context.push('/about_us'),
                slideAnimation: _slideAnimation,
                delay: 5,
                controller: _animationController,
              ),
              buildSettingItem(
                icon: FontAwesomeIcons.terminal,
                title: 'Terms & Conditions',
                onTap: () => context.push('/accessibility'),
                slideAnimation: _slideAnimation,
                delay: 5,
                controller: _animationController,
              ),
              buildSettingItem(
                icon: FontAwesomeIcons.fileCircleCheck,
                title: 'Privacy & Policy',
                onTap: () => context.push('/accessibility'),
                slideAnimation: _slideAnimation,
                delay: 5,
                controller: _animationController,
              ),
              buildSettingItem(
                icon: FontAwesomeIcons.fileContract,
                title: 'Contact Us',
                onTap: () => context.push('/contact-us'),
                slideAnimation: _slideAnimation,
                delay: 5,
                controller: _animationController,
              ),
              buildSettingItem(
                icon: FontAwesomeIcons.qrcode,
                title: 'Scan QR Code',
                onTap: () => context.push('/about_us'),
                slideAnimation: _slideAnimation,
                delay: 5,
                controller: _animationController,
              ),
              buildSettingItem(
                icon: FontAwesomeIcons.accessibleIcon,
                title: 'Accessibility',
                onTap: () => context.push('/accessibility'),
                slideAnimation: _slideAnimation,
                delay: 5,
                controller: _animationController,
              ),

              Divider(),
              buildHeader(label: 'Data'),

              // Clear Cache
              buildSettingItem(
                icon: Icons.cleaning_services,
                title: 'Clear Cache',
                onTap: () async {
                  await settingsViewModel.clearCache();
                  if (settingsViewModel.state == SettingsState.success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cache cleared successfully'),
                      ),
                    );
                  }
                },
                isLoading: settingsViewModel.state == SettingsState.loading,
                slideAnimation: _slideAnimation,
                delay: 4,
                controller: _animationController,
              ),

              // App Version
              buildSettingItem(
                icon: Icons.info,
                title: 'App Version',
                subtitle: settingsViewModel.appVersion,
                onTap: null,
                slideAnimation: _slideAnimation,
                delay: 5,
                controller: _animationController,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      title: Text(title),
      trailing: trailing ?? Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  Widget _buildToggleItem(
    BuildContext context, {
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      activeColor: Colors.green,
      onChanged: onChanged,
    );
  }
}
