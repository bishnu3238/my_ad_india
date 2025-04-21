
// src/presentation/widgets/social_login_button.dart
import 'package:flutter/material.dart';

enum SocialLoginProvider {
  google,
  facebook,
  twitter,
}

class SocialLoginButton extends StatelessWidget {
  final SocialLoginProvider provider;
  final VoidCallback onPressed;
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    String text;
    IconData? icon;
    Color backgroundColor;
    Color textColor;

    switch (provider) {
      case SocialLoginProvider.google:
        text = 'Continue with Google';
        icon = Icons.g_mobiledata_rounded;
        backgroundColor = Colors.white;
        textColor = Colors.black87;
        break;
      case SocialLoginProvider.facebook:
        text = 'Continue with Facebook';
        icon = Icons.facebook;
        backgroundColor = const Color(0xFF1877F2);
        textColor = Colors.white;
        break;
      case SocialLoginProvider.twitter:
        text = 'Continue with Twitter';
        icon = Icons.join_full;
        backgroundColor = const Color(0xFF1DA1F2);
        textColor = Colors.white;
        break;
    }

    final Widget buttonChild = isLoading
        ? SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(textColor),
      ),
    )
        : Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, color: textColor),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: TextStyle(color: textColor),
        ),
      ],
    );

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          elevation: 0,
        ),
        child: buttonChild,
      ),
    );
  }
}