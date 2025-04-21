import 'package:go_router/go_router.dart';

import 'package:flutter/material.dart';
import '../../../../../../core/data/model/model.dart';
import '../../../../../../provider_state/theme_provider.dart';
import '../../../../../../routes/auth/auth_routes.dart';

import 'local.dart';
import 'package:pack/auth/custom_auth.dart';
import 'package:pack/services/service.dart';
import 'dart:developer' as dev;

enum SettingsState { initial, loading, success, error }

class ProfileSettingsViewModel extends ChangeNotifier {
  final AuthProviderModel<UserModel> _authProvider;
  final AppVersionTracker _appVersionTracker;
  final LocalAppSettingStorage _storageService = LocalAppSettingStorage();
  final AppThemeProvider _appThemeProvider;

  ProfileSettingsViewModel(
    this._authProvider,
    this._appThemeProvider,
    this._appVersionTracker,
  ) {
    _authProvider.addListener(onAuthStateChanged);
    _appVersionTracker.addListener(_onVersionChanged);
    loadSettings();
  }
UserModel? _user;
  String _language = 'en';
  bool _isLoggedIn = false;
  bool _isDarkMode = false;
  String _errorMessage = '';
  String _appVersion = '1.0.0';
  bool _notificationsEnabled = true;
  SettingsState _state = SettingsState.initial;

  // Getters
  SettingsState get state => _state;
  bool get isLoggedIn => _isLoggedIn;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isDarkMode => _isDarkMode;
  String get language => _language;
  String get appVersion => _appVersion;
  String get errorMessage => _errorMessage;
  UserModel get user => _user ?? UserModel.empty;


  Future<void> checkAuthStatus() async {
    // Force refresh of auth status
    _isLoggedIn = await CustomAuth.isAuthenticated<UserModel>();
    _user = await CustomAuth.getCurrentUser<UserModel>();
    notifyListeners();
  }

  // Listener callback for AuthProviderModel changes
  void onAuthStateChanged() {
    dev.log(
      '[SettingsViewModel] Auth state changed: ${_authProvider.isAuthenticated} || ${_authProvider.errorMessage}',
    );

    _isLoggedIn = _authProvider.isAuthenticated;
    notifyListeners();
  }

  // Listener callback for AppVersionTracker changes
  void _onVersionChanged() {
    _appVersion =
        '${_appVersionTracker.appVersion} (Build ${_appVersionTracker.buildNumber})';
    notifyListeners();
  }

  // Load settings from local storage
  Future<void> loadSettings() async {
    _state = SettingsState.loading;
    notifyListeners();

    try {
      _isLoggedIn = _authProvider.isAuthenticated;
      final notificationsResult =
          await _storageService.getNotificationsEnabled();
      notificationsResult.fold(
        (failure) => throw failure,
        (enabled) => _notificationsEnabled = enabled,
      );
      _isDarkMode = _appThemeProvider.currentThemeMode == AppThemeMode.dark;
      final languageResult = await _storageService.getLanguage();
      languageResult.fold(
        (failure) => throw failure,
        (lang) => _language = lang,
      );
      _appVersion =
          '${_appVersionTracker.appVersion} (Build ${_appVersionTracker.buildNumber})';
      _state = SettingsState.success;
    } catch (e) {
      _state = SettingsState.error;
      _errorMessage = 'Failed to load settings: ${e.toString()}';
    }
    notifyListeners();
  }

  // Toggle notifications
  Future<void> toggleNotifications(bool value) async {
    _state = SettingsState.loading;
    notifyListeners();

    final result = await _storageService.saveNotificationsEnabled(value);

    result.fold(
      (failure) {
        _state = SettingsState.error;
        _errorMessage = failure.message;
      },
      (success) {
        _notificationsEnabled = value;
        _state = SettingsState.success;
      },
    );

    notifyListeners();
  }

  // Change theme
  Future<void> setThemeMode(bool isDark) async {
    _state = SettingsState.loading;
    notifyListeners();
    _appThemeProvider.setThemeMode(
      isDark ? AppThemeMode.dark : AppThemeMode.light,
    );
    notifyListeners();
  }

  // Change language
  Future<void> setLanguage(String language) async {
    _state = SettingsState.loading;
    notifyListeners();

    final result = await _storageService.saveLanguage(language);

    result.fold(
      (failure) {
        _state = SettingsState.error;
        _errorMessage = failure.message;
      },
      (success) {
        _language = language;
        _state = SettingsState.success;
      },
    );

    notifyListeners();
  }

  // Clear cache
  Future<void> clearCache() async {
    _state = SettingsState.loading;
    notifyListeners();

    final result = await _storageService.clearCache();

    result.fold(
      (failure) {
        _state = SettingsState.error;
        _errorMessage = failure.message;
      },
      (success) {
        _state = SettingsState.success;
      },
    );

    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    dev.log('Logout called');
    _state = SettingsState.loading;
    notifyListeners();
    try {
      final result = await _authProvider.logout();
      if (result) {
        dev.log('Logout successful $result');
        _isLoggedIn = false;
        _state = SettingsState.success;
        _authProvider.initialize();
      } else {
        _state = SettingsState.error;
        _errorMessage = "Logout request is cancel";
        _authProvider.initialize();
      }
      notifyListeners();
    } catch (e) {
      dev.log('Logout error: $e');
      _errorMessage = e.toString();
      _state = SettingsState.error;
    }
  }

  // Login (simulated)
  Future<void> login(BuildContext context) async {
    _state = SettingsState.loading;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      if (context.mounted) context.push(AuthRoutes.login);
    } catch (e) {
      _state = SettingsState.error;
      _errorMessage = 'Failed to login: ${e.toString()}';
    }

    notifyListeners();
  }

  void resetState() {
    _state = SettingsState.success;
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _authProvider.removeListener(onAuthStateChanged);
    _appVersionTracker.removeListener(_onVersionChanged); // Clean up listener
    super.dispose();
  }

  ProfileSettingsViewModel updateStore(AuthProviderModel<UserModel> auth) {
    _user =  auth.user;
    _isLoggedIn = auth.isAuthenticated;
    notifyListeners();

    return this;
  }
}
