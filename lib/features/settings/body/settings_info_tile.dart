// widgets/settings_info_tile.dart
import 'package:flutter/material.dart';

class SettingsInfoTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const SettingsInfoTile({
    Key? key,
    required this.title,
    required this.subtitle,
    this.onTap,
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
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}