import 'package:flutter/material.dart';
import '../core/theme/app_themes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_color_palette.dart';

enum AppThemeMode {
  light,
  dark,
  system
}

class AppThemeProvider extends ChangeNotifier {
  static const String _themePreferenceKey = 'app_theme_mode';

  late SharedPreferences _prefs;
  late AppThemeMode _currentThemeMode;
  late ThemeData _lightTheme;
  late ThemeData _darkTheme;
  final appTheme = AppTheme();

  AppThemeProvider() {
    _currentThemeMode = AppThemeMode.system;
    _initializeThemes();
  }

  Future<void> _initializeThemes() async {

    // Initialize themes
    _lightTheme = appTheme.lightTheme;
    _darkTheme = appTheme.darkTheme;
    _prefs = await SharedPreferences.getInstance();

    _currentThemeMode = _loadThemeMode();

    notifyListeners();
  }



  // Load Theme Mode from Preferences
  AppThemeMode _loadThemeMode() {
    final savedMode = _prefs.getString(_themePreferenceKey);
    return AppThemeMode.values.firstWhere(
            (mode) => mode.toString() == savedMode,
        orElse: () => AppThemeMode.system
    );
  }

  // Getters
  AppThemeMode get currentThemeMode => _currentThemeMode;
  ThemeData get lightTheme => _lightTheme;
  ThemeData get darkTheme => _darkTheme;
  bool get isDarkMode => _currentThemeMode == AppThemeMode.dark;

  // Theme Mode Management
  void setThemeMode(AppThemeMode mode) {
    _currentThemeMode = mode;
    _prefs.setString(_themePreferenceKey, mode.toString());
    notifyListeners();
  }

  // Dynamic Theme Customization
  void updatePrimaryColor(Color color) {
    // Update color scheme dynamically
    _lightTheme = appTheme.lightTheme.copyWith(
      colorScheme: AppColorPalette.lightColorScheme.copyWith(primary: color),
    );
    _darkTheme = appTheme.darkTheme.copyWith(
      colorScheme: AppColorPalette.darkColorScheme.copyWith(primary: color),
    );
    notifyListeners();
  }

  // Determine Current Theme Based on Mode
  ThemeData getThemeForMode(BuildContext context) {
    switch (_currentThemeMode) {
      case AppThemeMode.light:
        return _lightTheme;
      case AppThemeMode.dark:
        return _darkTheme;
      case AppThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark
            ? _darkTheme
            : _lightTheme;
    }
  }
}