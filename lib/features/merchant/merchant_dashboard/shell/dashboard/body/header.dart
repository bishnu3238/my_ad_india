import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_ad/core/domain/data_store/data_store.dart';
import 'package:my_ad/features/merchant/merchant_dashboard/shell/dashboard/body/profile_icon.dart';
import 'package:my_ad/utils/widgets/svg_icon_widget.dart';
import 'package:pack/pack.dart';
import 'package:pack/services/responsive_service/responsive_utils_advance.dart';
import 'package:pack/ui/widgets/responsive.dart';
import 'package:provider/provider.dart';
import '../../../../merchant_notification/core/notification_route.dart';

import '../../../merchant_dashboard_shell.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        if (!Responsive.isMobile(context))
          Text("Dashboard", style: Theme.of(context).textTheme.titleLarge),
        if (!Responsive.isMobile(context))
          Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
        Expanded(child: SearchField()),
        ProfileIcon(),
      ],
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(left: 16),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16 / 2),
      child: Row(
        children: [
          SvgIconWidget(
            iconPath: SvgIcons.profileIcon,
            height: 20,
            package: 'pack',
            colorFilter: ColorFilter.mode(theme.primary, BlendMode.srcIn),
          ),

          Icon(Icons.keyboard_arrow_down, color: theme.primary, size: 24),
        ],
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Container(
      width: MediaQuery.of(context).size.width * 1.2 / 3,
      padding: EdgeInsets.all(8),
      child: Consumer<MerchantDashboardStore>(
        builder: (context, store, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgIconWidget(
                iconPath: SvgIcons.userAvatarIcon,
                colorFilter: ColorFilter.mode(theme.primary, BlendMode.srcIn),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: AutoSizeText(
                  'Welcome \n${store.entity!.merchantData.merchant.username}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: ScreenUtils().getFontSize(15),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SvgIconWidget(
                onTap: ()=>context.push(NotificationRoute.notification),
                iconPath: SvgIcons.notificationIcon,
                colorFilter: ColorFilter.mode(theme.primary, BlendMode.srcIn),
              ),
            ],
          );
        },
      ),
    );

    //   TextField(
    //   decoration: InputDecoration(
    //     hintText: "Search",
    //     fillColor: secondaryColor,
    //     filled: true,
    //     border: OutlineInputBorder(
    //       borderSide: BorderSide.none,
    //       borderRadius: const BorderRadius.all(Radius.circular(10)),
    //     ),
    //     isDense: true,
    //     suffixIcon: InkWell(
    //       onTap: () {},
    //       child: Padding(
    //         padding: const EdgeInsets.all(8.0),
    //         child: FittedBox(
    //           child: SvgIconWidget(
    //             iconPath: SvgIcons.searchBoldIcon,
    //             width: 5,
    //             height: 5,
    //             package: 'pack',
    //             colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
