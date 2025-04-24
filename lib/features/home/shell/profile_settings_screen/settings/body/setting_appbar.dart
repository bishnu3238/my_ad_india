import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pack/pack.dart';
import 'package:provider/provider.dart';

import '../../../../../../utils/handler/back_gesture_handler.dart';
import '../../../../../../utils/widgets/svg_icon_widget.dart';
import '../../../../core/home_provider.dart';

class SettingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String label;
  final bool showLeading;
  final List<Widget>? actions;

  const SettingAppBar({
    super.key,
    required this.label,
    this.showLeading = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(label),
      automaticallyImplyLeading: showLeading,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => _handleBackPress(context),
      ),
      actions: [
        ...actions ?? [],
        Padding(
          padding: 20.symmetricHV(0),
          child: SvgIconWidget(
            onTap: () {},
            width: 25,
            height: 25,
            iconPath: SvgIcons.notificationIcon,
            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  void _handleBackPress(BuildContext context) {
    final shell = context.read<HomeProvider>().shell;

    if (shell.currentIndex != 0) {
      BackGestureHandler.handleBackPress(context, shell);
    }
  }
}
