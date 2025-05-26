import 'package:flutter/material.dart';
import 'package:pack/services/service.dart';
import 'package:provider/provider.dart';
import 'core/settings_provider.dart';
import 'core/settings_state.dart';

class MerchantSettingsPage extends StatefulWidget {
  const MerchantSettingsPage({super.key});

  @override
  State<MerchantSettingsPage> createState() => _MerchantSettingsPageState();
}

class _MerchantSettingsPageState extends State<MerchantSettingsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(), // Added for About tab
  ];

  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _contactEmailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _businessAddressController =
      TextEditingController();
  final TextEditingController _businessDescriptionController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this); // Updated to 7 tabs

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SettingsProvider>(context, listen: false);
      _businessNameController.text = provider.state.businessName;
      _contactEmailController.text = provider.state.contactEmail;
      _phoneNumberController.text = provider.state.phoneNumber;
      _businessAddressController.text = provider.state.businessAddress;
      _businessDescriptionController.text = provider.state.businessDescription;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _businessNameController.dispose();
    _contactEmailController.dispose();
    _phoneNumberController.dispose();
    _businessAddressController.dispose();
    _businessDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: _buildAppBar(context, settingsProvider),
          body: _buildBody(context, settingsProvider),
          floatingActionButton: _buildFloatingActionButton(
            context,
            settingsProvider,
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    SettingsProvider provider,
  ) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      title: const Text(
        'Settings',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
      ),
      centerTitle: true,
      actions: [
        if (provider.state.isLoading)
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleMenuAction(context, provider, value),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'save',
                    child: ListTile(
                      leading: Icon(Icons.save),
                      title: Text('Save All'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'backup',
                    child: ListTile(
                      leading: Icon(Icons.cloud_upload),
                      title: Text('Backup to Cloud'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'restore',
                    child: ListTile(
                      leading: Icon(Icons.cloud_download),
                      title: Text('Restore from Cloud'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'reset',
                    child: ListTile(
                      leading: Icon(Icons.refresh, color: Colors.red),
                      title: Text(
                        'Reset to Defaults',
                        style: TextStyle(color: Colors.red),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
          ),
      ],
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        indicatorColor: Theme.of(context).colorScheme.primary,
        tabs: const [
          Tab(text: 'Profile', icon: Icon(Icons.business, size: 20)),
          Tab(
            text: 'Service',
            icon: Icon(Icons.settings_applications, size: 20),
          ),
          Tab(text: 'Notifications', icon: Icon(Icons.notifications, size: 20)),
          Tab(text: 'Privacy', icon: Icon(Icons.privacy_tip, size: 20)),
          Tab(text: 'Security', icon: Icon(Icons.security, size: 20)),
          Tab(text: 'Display', icon: Icon(Icons.display_settings, size: 20)),
          Tab(text: 'About', icon: Icon(Icons.info, size: 20)), // New About tab
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, SettingsProvider provider) {
    if (provider.state.hasError) {
      return _buildErrorState(context, provider);
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildBusinessProfileTab(context, provider),
        _buildServiceConfigTab(context, provider),
        _buildNotificationsTab(context, provider),
        _buildPrivacyTab(context, provider),
        _buildSecurityTab(context, provider),
        _buildDisplayTab(context, provider),
        _buildAboutTab(context), // New About tab
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, SettingsProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.state.errorMessage ?? 'Unknown error occurred',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.clearError(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessProfileTab(
    BuildContext context,
    SettingsProvider provider,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              'Business Information',
              Icons.business,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _businessNameController,
              label: 'Business Name',
              icon: Icons.store,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              onChanged: (value) => provider.state.updateBusinessName(value),
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _contactEmailController,
              label: 'Contact Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}',
                ).hasMatch(value!)) {
                  return 'Invalid email format';
                }
                return null;
              },
              onChanged: (value) => provider.state.updateContactEmail(value),
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _phoneNumberController,
              label: 'Phone Number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              onChanged: (value) => provider.state.updatePhoneNumber(value),
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _businessAddressController,
              label: 'Business Address',
              icon: Icons.location_on,
              maxLines: 3,
              onChanged: (value) => provider.state.updateBusinessAddress(value),
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _businessDescriptionController,
              label: 'Business Description',
              icon: Icons.description,
              maxLines: 4,
              onChanged:
                  (value) => provider.state.updateBusinessDescription(value),
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: 'Business Category',
              icon: Icons.category,
              value: provider.state.businessCategory,
              items: provider.getBusinessCategories(),
              onChanged:
                  (value) => provider.state.updateBusinessCategory(value!),
            ),
            const SizedBox(height: 24),
            _buildSaveButton(
              'Save Business Profile',
              () => _saveBusinessProfile(provider),
              provider.state.isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceConfigTab(
    BuildContext context,
    SettingsProvider provider,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            context,
            'Service Configuration',
            Icons.settings_applications,
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'Service Enabled',
            'Enable or disable your service',
            Icons.power_settings_new,
            provider.state.serviceEnabled,
            (value) => provider.toggleService(),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'Auto-Accept Orders',
            'Automatically accept incoming orders',
            Icons.auto_mode,
            provider.state.autoAcceptOrders,
            (value) => provider.toggleAutoAcceptOrders(),
          ),
          const SizedBox(height: 24),
          _buildSliderCard(
            'Maximum Concurrent Orders',
            'Set the maximum number of orders you can handle simultaneously',
            Icons.queue,
            provider.state.maxConcurrentOrders.toDouble(),
            1.0,
            100.0,
            10,
            (value) => provider.updateMaxConcurrentOrders(value.round()),
          ),
          const SizedBox(height: 16),
          _buildSliderCard(
            'Service Fee Percentage',
            'Set your service fee as a percentage',
            Icons.percent,
            provider.state.serviceFeePercentage,
            0.0,
            20.0,
            4,
            (value) => provider.updateServiceFeePercentage(value),
            suffix: '%',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab(
    BuildContext context,
    SettingsProvider provider,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            context,
            'Notification Preferences',
            Icons.notifications,
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'Push Notifications',
            'Receive push notifications on your device',
            Icons.notifications_active,
            provider.state.pushNotificationsEnabled,
            (value) => provider.togglePushNotifications(),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'Email Notifications',
            'Receive notifications via email',
            Icons.email,
            provider.state.emailNotificationsEnabled,
            (value) => provider.toggleEmailNotifications(),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'SMS Notifications',
            'Receive notifications via SMS',
            Icons.sms,
            provider.state.smsNotificationsEnabled,
            (value) => provider.toggleSmsNotifications(),
          ),
          const SizedBox(height: 24),
          _buildRadioCard(
            'Notification Frequency',
            'How often should you receive notifications?',
            Icons.schedule,
            NotificationFrequency.values,
            provider.state.notificationFrequency,
            (value) => provider.updateNotificationFrequency(value),
            (frequency) => _getNotificationFrequencyLabel(frequency),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyTab(BuildContext context, SettingsProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, 'Data & Privacy', Icons.privacy_tip),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'Analytics',
            'Help improve the app by sharing usage data',
            Icons.analytics,
            provider.state.analyticsEnabled,
            (value) => provider.toggleAnalytics(),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'Data Sharing',
            'Share data with partner services',
            Icons.share,
            provider.state.dataSharingEnabled,
            (value) => provider.toggleDataSharing(),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'Automatic Backup',
            'Automatically backup your settings to cloud',
            Icons.backup,
            provider.state.backupEnabled,
            (value) => provider.toggleBackup(),
          ),
          const SizedBox(height: 24),
          _buildRadioCard(
            'Data Sync Interval',
            'How often should data be synchronized?',
            Icons.sync,
            DataSyncInterval.values,
            provider.state.dataSyncInterval,
            (value) => provider.updateDataSyncInterval(value),
            (interval) => _getDataSyncIntervalLabel(interval),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTab(BuildContext context, SettingsProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, 'Security Settings', Icons.security),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'Two-Factor Authentication',
            'Add an extra layer of security',
            Icons.lock,
            provider.state.twoFactorEnabled,
            (value) => provider.toggleTwoFactor(),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'Biometric Authentication',
            'Use fingerprint or face recognition',
            Icons.fingerprint,
            provider.state.biometricAuthEnabled,
            (value) => provider.toggleBiometricAuth(),
          ),
          const SizedBox(height: 24),
          _buildSliderCard(
            'Session Timeout',
            'Automatically log out after inactivity',
            Icons.timer,
            provider.state.sessionTimeoutMinutes.toDouble(),
            5.0,
            480.0,
            10,
            (value) => provider.updateSessionTimeout(value.round()),
            suffix: ' min',
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayTab(BuildContext context, SettingsProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            context,
            'Display Settings',
            Icons.display_settings,
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'Dark Mode',
            'Switch to dark theme',
            Icons.dark_mode,
            provider.state.darkModeEnabled,
            (value) => provider.toggleDarkMode(context),
          ),
          const SizedBox(height: 24),
          _buildSliderCard(
            'Font Size',
            'Adjust text size for better readability',
            Icons.text_fields,
            provider.state.fontSize,
            12.0,
            24.0,
            2,
            (value) => provider.updateFontSize(value),
            suffix: 'pt',
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Language',
            icon: Icons.language,
            value: provider.state.language,
            items: provider.getAvailableLanguages(),
            onChanged: (value) => provider.updateLanguage(value!),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab(BuildContext context) {
    return Consumer<AppVersionTracker>(
      builder: (context, versionTracker, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context, 'About', Icons.info),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'App Version',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        versionTracker.appVersion,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Build Number',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        versionTracker.buildNumber,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Package Name',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        versionTracker.packageName,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Function(String)? onChanged,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      items:
          items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle),
        secondary: Icon(icon),
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildSliderCard(
    String title,
    String subtitle,
    IconData icon,
    double value,
    double min,
    double max,
    int divisions,
    Function(double) onChanged, {
    String suffix = '',
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${value.toStringAsFixed(suffix == '%' ? 1 : 0)}$suffix',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioCard<T>(
    String title,
    String subtitle,
    IconData icon,
    List<T> options,
    T selectedValue,
    Function(T) onChanged,
    String Function(T) labelBuilder,
  ) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...options.map(
              (option) => RadioListTile<T>(
                title: Text(labelBuilder(option)),
                value: option,
                groupValue: selectedValue,
                onChanged: (value) => onChanged(value!),
                contentPadding: EdgeInsets.zero,
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(String text, VoidCallback onPressed, bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child:
            isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
      ),
    );
  }

  Widget? _buildFloatingActionButton(
    BuildContext context,
    SettingsProvider provider,
  ) {
    if (provider.state.isLoading) return null;

    return FloatingActionButton.extended(
      onPressed: () => provider.saveAllSettings(),
      icon: const Icon(Icons.save),
      label: const Text('Save All'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );
  }

  void _handleMenuAction(
    BuildContext context,
    SettingsProvider provider,
    String action,
  ) {
    switch (action) {
      case 'save':
        provider.saveAllSettings();
        _showSnackBar('Settings saved successfully');
        break;
      case 'backup':
        provider.backupToCloud();
        _showSnackBar('Backing up to cloud...');
        break;
      case 'restore':
        provider.restoreFromCloud(context);
        _showSnackBar('Restoring from cloud...');
        break;
      case 'reset':
        _showResetConfirmationDialog(provider);
        break;
    }
  }

  void _saveBusinessProfile(SettingsProvider provider) {
    if (_formKeys[0].currentState?.validate() ?? false) {
      provider.updateBusinessProfile(
        businessName: _businessNameController.text,
        contactEmail: _contactEmailController.text,
        phoneNumber: _phoneNumberController.text,
        businessAddress: _businessAddressController.text,
        businessDescription: _businessDescriptionController.text,
        businessCategory: provider.state.businessCategory,
      );
      _showSnackBar('Business profile saved successfully');
    }
  }

  void _showResetConfirmationDialog(SettingsProvider provider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset Settings'),
            content: const Text(
              'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  provider.resetToDefaults(context);
                  _showSnackBar('Settings reset to defaults');
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Reset'),
              ),
            ],
          ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _getNotificationFrequencyLabel(NotificationFrequency frequency) {
    switch (frequency) {
      case NotificationFrequency.immediate:
        return 'Immediate';
      case NotificationFrequency.hourly:
        return 'Hourly';
      case NotificationFrequency.daily:
        return 'Daily';
      case NotificationFrequency.weekly:
        return 'Weekly';
    }
  }

  String _getDataSyncIntervalLabel(DataSyncInterval interval) {
    switch (interval) {
      case DataSyncInterval.realtime:
        return 'Real-time';
      case DataSyncInterval.minutes5:
        return 'Every 5 minutes';
      case DataSyncInterval.minutes15:
        return 'Every 15 minutes';
      case DataSyncInterval.minutes30:
        return 'Every 30 minutes';
      case DataSyncInterval.hourly:
        return 'Hourly';
    }
  }
}
