// lib/screens/settings_page.dart (continued)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'component/login_settings_page.dart';
import 'component/logout_settings_page.dart';
import 'core/setting_view_model.dart';
import 'dart:developer' as dev;
import 'package:flutter/cupertino.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check auth status when dependencies change (which happens during navigation)
    Provider.of<ProfileSettingsViewModel>(context, listen: false).checkAuthStatus();
  }



  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Provider.of<ProfileSettingsViewModel>(context, listen: false).checkAuthStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileSettingsViewModel>(
      builder: (context, settingsViewModel, _) {
        if (settingsViewModel.isLoggedIn) {
          return LoggedInSettingsPage(user: settingsViewModel.user);
        } else {
          return const LoggedOutSettingsPage();
        }
      },
    );
  }
}
