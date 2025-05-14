import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'component/login_settings_page.dart';
import 'component/logout_settings_page.dart';
import 'component/error_view.dart';
import 'component/loading_view.dart';
import 'core/setting_view_model.dart';
import 'dart:developer' as dev;

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen>
    with WidgetsBindingObserver {
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    try {
      await _checkAuthStatus();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      dev.log('Error initializing settings: $e');
      // Error will be handled in the build method
    }
  }

  Future<void> _checkAuthStatus() async {
    if (!mounted) return;
    await Provider.of<ProfileSettingsViewModel>(context, listen: false).checkAuthStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAuthStatus();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAuthStatus();
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
        // Handle loading state
        if (!_isInitialized) {
          return const LoadingView();
        }
        
        // Handle error state
        if (settingsViewModel.state == SettingsState.error) {
          return ErrorView(
            errorMessage: settingsViewModel.errorMessage,
            onRetry: _checkAuthStatus,
          );
        }
        
        // Show appropriate view based on login status
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildContentView(settingsViewModel),
        );
      },
    );
  }
  
  Widget _buildContentView(ProfileSettingsViewModel viewModel) {
    if (viewModel.isLoggedIn) {
      return LoggedInSettingsPage(
        key: const ValueKey('logged_in'),
        user: viewModel.user,
      );
    } else {
      return const LoggedOutSettingsPage(
        key: ValueKey('logged_out'),
      );
    }
  }
}
