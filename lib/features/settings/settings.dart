// settings_screen.dart
import 'package:flutter/material.dart';
import 'package:my_ad/core/data/model/model.dart';
import 'package:my_ad/core/injector/dependency_injection.dart';
import 'package:my_ad/provider_state/theme_provider.dart';
import 'package:pack/auth/custom_auth.dart';
import 'package:provider/provider.dart';
import 'body/settings_info_tile.dart';
import 'body/settings_navigation_tile.dart';
import 'body/settings_radio_tile.dart';
import 'body/settings_section_header.dart';
import 'body/settings_switch_tile.dart';
import 'core/settings_state.dart';
import 'core/settings_view_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => DependencyInjector.getWithParams<
            SettingsViewModel,
            AppThemeProvider,
            UserModel
          >(
            param1: context.read<AppThemeProvider>(),
            param2:
                context.read<AuthProviderModel<UserModel>>().user ??
                UserModel.empty,
          ),
      child: const _SettingsScreenContent(),
    );
  }
}

class _SettingsScreenContent extends StatelessWidget {
  const _SettingsScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SettingsViewModel>(context);
    final state = viewModel.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0.5,
      ),
      body: ListView(
        children: [
          // User Settings Section
          const SettingsSectionHeader(title: 'USER SETTINGS'),
          SettingsInfoTile(
            title: 'Display Name',
            subtitle: state.userName,
            onTap: () => viewModel.navigateToEditProfile(context),
          ),

          // Local Contacts Section
          const SettingsSectionHeader(title: 'LOCAL CONTACTS'),
          SettingsInfoTile(
            title: 'Phonebook country',
            subtitle: state.country,
            onTap: () => viewModel.navigateToCountrySelection(context),
          ),

          // Notifications Section
          const SettingsSectionHeader(title: 'NOTIFICATIONS'),
          SettingsSwitchTile(
            title: 'Enable notifications for this account',
            value: state.notificationsEnabled,
            onChanged: (value) => viewModel.updateNotificationsEnabled(value),
          ),
          SettingsSwitchTile(
            title: 'Enable full page notification',
            value: state.fullPageNotificationsEnabled,
            onChanged: (value) => viewModel.updateFullPageNotifications(value),
          ),
          SettingsNavigationTile(
            title: 'Notification Settings',
            onTap: () => viewModel.navigateToNotificationSettings(context),
          ),

          // Autoplay Section
          const SettingsSectionHeader(title: 'AUTOPLAY'),
          SettingsRadioTile<AutoplayOption>(
            title: 'On Mobile Data and Wi-Fi Connections',
            value: AutoplayOption.always,
            groupValue: state.autoplayOption,
            onChanged: (value) => viewModel.updateAutoplayOption(value!),
          ),
          SettingsRadioTile<AutoplayOption>(
            title: 'On Wi-Fi Connections only',
            value: AutoplayOption.wifiOnly,
            groupValue: state.autoplayOption,
            onChanged: (value) => viewModel.updateAutoplayOption(value!),
          ),
          SettingsRadioTile<AutoplayOption>(
            title: 'Never Autoplay Videos',
            value: AutoplayOption.never,
            groupValue: state.autoplayOption,
            onChanged: (value) => viewModel.updateAutoplayOption(value!),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              'If your battery is low we turn off autoplay',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          // Other Section
          const SettingsSectionHeader(title: 'OTHER'),
          SettingsNavigationTile(
            title: 'Application info',
            subtitle: 'Application system info screen',
            onTap: () => viewModel.navigateToAppInfo(context),
          ),

          SettingsNavigationTile(
            title: 'Privacy Settings',
            onTap: () => viewModel.navigateToPrivacySettings(context),
          ),
          SettingsInfoTile(
            title: 'Version',
            subtitle: state.appVersion,
            onTap: null,
          ),
          SettingsNavigationTile(
            title: 'Copyright',
            onTap: () => viewModel.navigateToCopyright(context),
          ),
          SettingsNavigationTile(
            title: 'Terms & conditions',
            onTap: () => viewModel.navigateToTerms(context),
          ),
          SettingsNavigationTile(
            title: 'Privacy policy',
            onTap: () => viewModel.navigateToPrivacyPolicy(context),
          ),
          SettingsNavigationTile(
            title: 'Third party notices',
            onTap: () => viewModel.navigateToThirdPartyNotices(context),
          ),
          SettingsNavigationTile(
            title: 'Support',
            onTap: () => viewModel.navigateToSupport(context),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
