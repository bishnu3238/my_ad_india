import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_ad/core/domain/data_store/data_store.dart';
import 'package:my_ad/features/merchant/merchant_dashboard/core/merchant_dashboard_route.dart';
import 'package:my_ad/features/merchant/merchant_dashboard/shell/merchant_add_service/core/merchant_add_service_route.dart';
import 'package:my_ad/features/merchant/merchant_dashboard/shell/merchant_add_service/merchant_add_service_screen.dart';
import 'package:pack/resources/svg_icons.dart';
import 'package:pack/ui/widgets/responsive.dart';
import 'package:provider/provider.dart';

import '../../../merchant_dashboard_shell.dart';
import 'card_view_info.dart';

import '../../../merchant_dashboard_shell.dart';

import 'dashboard_card_items.dart';

class MyServices extends StatelessWidget {
  const MyServices({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "My Dashboard",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
            ElevatedButton.icon(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () => context.push(MerchantDashboardRoute.addService),
              icon: Icon(Icons.add),
              label: Text("Add New"),
            ),
          ],
        ),
        SizedBox(height: 16),
        DashboardCardView(
          crossAxisCount: size.width < 650 ? 2 : 4,
          childAspectRatio: size.width < 650 && size.width > 350 ? 1.3 : 1,
        ),
      ],
    );
  }
}

class DashboardCardView extends StatelessWidget {
  const DashboardCardView({
    super.key,
    this.crossAxisCount = 4,
    this.childAspectRatio = 1,
  });

  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    List<DashboardGridInfo> gridInfos = createCards(context);

    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: gridInfos.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder:
          (context, index) => CardViewInfo(
            info: gridInfos[index],
            onTap: (BuildContext context) => gridInfos[index].onTap(context),
          ),
    );
  }

  List<DashboardGridInfo> createCards(BuildContext context) {
    final store = context.watch<MerchantDashboardStore>();

    final planModel = store.entity?.planAccess;
    final percentage =
        (((planModel!.numberOfServices - planModel.remainingServices) /
                planModel.numberOfServices) *
            100);
    dev.log('Percentage: $percentage');
    return [
      DashboardGridInfo(
        title: "Services",
        subTitle:
            '${planModel.numberOfServices - planModel.remainingServices} / ${planModel.numberOfServices}',
        numOfServices: planModel.numberOfServices,
        svgSrc: SvgIcons.product,
        percentage: percentage,
        onTap: (BuildContext ctx) => ctx.push(MerchantDashboardRoute.services),
      ),
      DashboardGridInfo(
        title: "Customer",
        numOfServices: 0,
        svgSrc: SvgIcons.profileIcon,
        percentage: 35,
        subTitle: '',
        onTap: (context) => context.pop(),
      ),
      DashboardGridInfo(
        title: "Report",
        numOfServices: 0,
        svgSrc: SvgIcons.filterIcon,
        percentage: 10,
        subTitle: '',
        onTap: (context) => context.pop(),
      ),
      DashboardGridInfo(
        title: "Refer & Earn",
        numOfServices: 0,
        svgSrc: SvgIcons.diamond,
        percentage: 78,
        subTitle: '',
        onTap: (context) => context.pop(),
      ),
    ];
  }
}
