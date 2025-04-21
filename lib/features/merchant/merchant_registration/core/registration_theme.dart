import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// A class that defines the theme for the merchant registration process
class RegistrationTheme {
  // Primary colors
  static const Color primaryColor = Color(0xFF007AFF); // iOS blue
  static const Color secondaryColor = Color(0xFF5AC8FA); // iOS light blue
  static const Color accentColor = Color(0xFF34C759); // iOS green
  static const Color errorColor = Color(0xFFFF3B30); // iOS red
  static const Color warningColor = Color(0xFFFF9500); // iOS orange

  // Background colors
  static const Color scaffoldBackgroundColor = Color(
    0xFFF2F2F7,
  ); // iOS light gray
  static const Color cardBackgroundColor = Colors.white;
  static const Color dividerColor = Color(0xFFC6C6C8); // iOS divider color

  // Text colors
  static const Color primaryTextColor = Color(0xFF000000);
  static const Color secondaryTextColor = Color(0xFF8E8E93);
  static const Color disabledTextColor = Color(0xFFC7C7CC);
  static const Color secondaryButtonColor = Color(
    0xFFE5E5EA,
  ); // iOS light gray button

  // Input decoration theme
  static InputDecorationTheme inputDecorationTheme(BuildContext context) {
    return Theme.of(context).inputDecorationTheme.copyWith(
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: errorColor),
      ),
      labelStyle: TextStyle(color: secondaryTextColor),
      hintStyle: TextStyle(color: secondaryTextColor),
      errorStyle: TextStyle(color: errorColor),
    );
  }

  // Button themes
  static ButtonStyle get primaryButtonStyle {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.disabled)) {
          return primaryColor.withValues(alpha: 0.5);
        }
        return primaryColor;
      }),
      foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      padding: WidgetStateProperty.all<EdgeInsets>(
        const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
      textStyle: WidgetStateProperty.all<TextStyle>(
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  static ButtonStyle get secondaryButtonStyle {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.disabled)) {
          return secondaryButtonColor.withValues(alpha: 0.5);
        }
        return secondaryButtonColor;
      }),
      foregroundColor: WidgetStateProperty.all<Color>(primaryColor),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: primaryColor),
        ),
      ),
      padding: WidgetStateProperty.all<EdgeInsets>(
        const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
      textStyle: WidgetStateProperty.all<TextStyle>(
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  // Text themes
  static TextStyle titleLarge(BuildContext context, [Color? color]) {
    final theme = Theme.of(context);
    return theme.textTheme.titleLarge!.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: color ??primaryTextColor,
    );
  }

  static TextStyle titleMedium(BuildContext context, [Color? color]) {
    final theme = Theme.of(context);
    return theme.textTheme.titleMedium!.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color:color ?? primaryTextColor,
    );
  }

  static TextStyle titleSmall(BuildContext context, [Color? color]) {
    final theme = Theme.of(context);
    return theme.textTheme.titleSmall!.copyWith(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: color ??primaryTextColor,
    );
  }

  static TextStyle bodyLarge(BuildContext context, [Color? color]) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyLarge!.copyWith(
      fontSize: 17,
      fontWeight: FontWeight.normal,
      color:color ?? primaryTextColor,
    );
  }

  static TextStyle bodyMedium({required BuildContext context, Color? color,  FontWeight? fontWeight}) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyMedium!.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.normal,
      color: color ?? primaryTextColor,
    );
  }

  static TextStyle get bodySmall {
    return const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.normal,
      color: secondaryTextColor,
    );
  }

  // Card decoration
  static BoxDecoration get cardDecoration {
    return BoxDecoration(
      color: cardBackgroundColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Timeline decoration
  static BoxDecoration get timelineItemActive {
    return BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      border: Border.all(color: primaryColor, width: 2),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration get timelineItemCompleted {
    return BoxDecoration(
      color: accentColor,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: accentColor.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration get timelineItemInactive {
    return BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      border: Border.all(color: dividerColor, width: 1),
    );
  }

  // Input Decorations
  static InputDecoration inputDecoration(String label, BuildContext context) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      labelStyle: theme.textTheme.bodySmall?.copyWith(
        color: secondaryTextColor,
        fontSize: 16,
      ), // const TextStyle(color: secondaryTextColor, fontSize: 16),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: dividerColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: dividerColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
    );
  }
}
