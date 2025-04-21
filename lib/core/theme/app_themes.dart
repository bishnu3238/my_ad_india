import 'package:flutter/material.dart';

import 'app_color_palette.dart';

class AppTheme {

// Create Light Theme
ThemeData _createLightTheme() {
  return ThemeData(
    colorScheme: AppColorPalette.lightColorScheme,
    fontFamily: 'Roboto',
    brightness: Brightness.light,

 );
}

// Create Dark Theme
ThemeData _createDarkTheme() {
  return ThemeData(
    colorScheme: AppColorPalette.darkColorScheme,
    fontFamily: 'Roboto',
    brightness: Brightness.dark,

     );
}


ThemeData get lightTheme => _createLightTheme();
ThemeData get darkTheme => _createDarkTheme();


}