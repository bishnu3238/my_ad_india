// widgets/settings_navigation_tile.dart
import 'package:flutter/material.dart';

class SettingsNavigationTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final String? subtitle;
  final Widget? trailing;

  const SettingsNavigationTile({
    Key? key,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
