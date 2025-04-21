import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class HeaderCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onBackPressed;

  const HeaderCard({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: backgroundColor ?? CupertinoColors.systemBackground,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            if (onBackPressed != null)
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onBackPressed,
                child: const Icon(
                  CupertinoIcons.back,
                  color: CupertinoColors.activeBlue,
                ),
              ),
            if (icon != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor?.withOpacity(0.1) ?? CupertinoColors.activeBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? CupertinoColors.activeBlue,
                  size: 24,
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    semanticsLabel: 'Header title: $title',
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.secondaryLabel.resolveFrom(context),
                        ),
                        semanticsLabel: 'Header subtitle: $subtitle',
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
