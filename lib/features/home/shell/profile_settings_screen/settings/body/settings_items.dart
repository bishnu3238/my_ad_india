import 'package:flutter/material.dart';

import '../core/setting_view_model.dart';

class BuildSettingItems extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
 final  bool isLoading;
   final int delay;
   const BuildSettingItems({
    super.key,
    required this. icon,
    required this. title,
    this. subtitle,
    required this. onTap,
    this. isLoading = false,
    required this. delay,
  });

  @override
  State<BuildSettingItems> createState() => _BuildSettingItemsState();
}

class _BuildSettingItemsState extends State<BuildSettingItems>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Load settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final delayedAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent:_animationController,
            curve: Interval(widget.delay * 0.1, 1.0, curve: Curves.easeOut),
          ),
        );

        return FadeTransition(
          opacity: delayedAnimation,
          child: SlideTransition(position: _slideAnimation, child: child),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(widget.icon, color: Colors.blue.shade700),
          title: Text(widget.title),
          subtitle: widget.subtitle != null ? Text(widget.subtitle!) : null,
          trailing:
          widget.isLoading
                  ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue.shade700,
                      ),
                    ),
                  )
                  :widget. onTap != null
                  ? const Icon(Icons.chevron_right)
                  : null,
          onTap: widget.isLoading ? null :widget. onTap,
        ),
      ),
    );
  }
}

Widget buildSettingItem({
  required IconData icon,
  required String title,
  String? subtitle,
  required VoidCallback? onTap,
  bool isLoading = false,
  required AnimationController controller,
  required Animation<Offset> slideAnimation,
  required int delay,
}) {
  return AnimatedBuilder(
    animation: controller,
    builder: (context, child) {
      final delayedAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(delay * 0.1, 1.0, curve: Curves.easeOut),
        ),
      );

      return FadeTransition(
        opacity: delayedAnimation,
        child: SlideTransition(position: slideAnimation, child: child),
      );
    },
    child: Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade700),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing:
            isLoading
                ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue.shade700,
                    ),
                  ),
                )
                : onTap != null
                ? const Icon(Icons.chevron_right)
                : null,
        onTap: isLoading ? null : onTap,
      ),
    ),
  );
}

Widget buildHeader({String? label = '', VoidCallback? onTap}) => Padding(
  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  child: InkWell(
    onTap: onTap,
    child: Text(
      label ?? '',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    ),
  ),
);

Widget buildSettingItemWithSwitch({
  required IconData icon,
  required String title,
  required bool value,
  required ValueChanged<bool> onChanged,
  required Animation<Offset> slideAnimation,
  required int delay,
  required AnimationController controller,
}) {
  return AnimatedBuilder(
    animation: controller,
    builder: (context, child) {
      final delayedAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(delay * 0.1, 1.0, curve: Curves.easeOut),
        ),
      );

      return FadeTransition(
        opacity: delayedAnimation,
        child: SlideTransition(position: slideAnimation, child: child),
      );
    },
    child: Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        secondary: Icon(icon, color: Colors.blue.shade700),
        title: Text(title),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue.shade700,
      ),
    ),
  );
}

String getLanguageName(String code) {
  switch (code) {
    case 'en':
      return 'English';
    case 'es':
      return 'Spanish';
    case 'fr':
      return 'French';
    case 'de':
      return 'German';
    default:
      return 'English';
  }
}

void showLanguageDialog(ProfileSettingsViewModel viewModel, BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildLanguageOption('en', 'English', viewModel, context),
            buildLanguageOption('es', 'Spanish', viewModel, context),
            buildLanguageOption('fr', 'French', viewModel, context),
            buildLanguageOption('de', 'German', viewModel, context),
          ],
        ),
      );
    },
  );
}

Widget buildLanguageOption(
  String code,
  String name,
  ProfileSettingsViewModel viewModel,
  BuildContext context,
) {
  return ListTile(
    title: Text(name),
    trailing:
        viewModel.language == code
            ? Icon(Icons.check, color: Colors.blue.shade700)
            : null,
    onTap: () {
      viewModel.setLanguage(code);
      Navigator.pop(context);
    },
  );
}
