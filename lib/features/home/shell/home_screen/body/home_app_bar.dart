import 'package:flutter/material.dart';
import 'package:my_ad/utils/includes/app_drawer_wrapper.dart';
import 'package:pack/pack.dart';
import '../../../../../routes/auth/auth_routes.dart';
import '../../../../../utils/widgets/svg_icon_widget.dart';
import '../../../../location/core/location_navigator.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../../provider_state/location_provider.dart';
import '../../../core/first_time_popup_manager.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Consumer<LocationProvider>(
        builder: (context, locationService, _) {
          return GestureDetector(
            onTap: () => context.push(LocationRoute.location),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, size: 18),
                const SizedBox(width: 4),
                Text(locationService.currentLocation),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          );
        },
      ),
      actions: [
        Padding(
          padding: 20.symmetricHV(0),
          child: SvgIconWidget(
            iconPath: SvgIcons.userProfileCircleIcon,
            onTap: () {
              context.openDrawer();
              // FirstTimePopupManager.showReferralPopupIfNeeded(context);
            },
            width: 25,
            height: 25,
            colorFilter: ColorFilter.mode(
              context.colorScheme.onSurface,
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
