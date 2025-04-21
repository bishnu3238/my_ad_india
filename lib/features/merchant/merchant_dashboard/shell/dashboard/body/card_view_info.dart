import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../utils/widgets/svg_icon_widget.dart';
import '../../../core/merchant_dashboard_shell_provider.dart';
import '../../../merchant_dashboard_shell.dart';

import 'dashboard_card_items.dart';

class CardViewInfo extends StatelessWidget {
  const CardViewInfo({super.key, required this.info, required this.onTap});

  final DashboardGridInfo info;
  final Function(BuildContext context) onTap;

  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantDashboardShellProvider>(
      builder: (context, provider, child) {
        final theme = Theme.of(context).colorScheme;
        return GestureDetector(
          onTap: () => onTap(context),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: theme.primaryContainer.withValues(alpha: 0.1),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: SvgIconWidget(
                          iconPath: info.svgSrc!,
                          colorFilter: ColorFilter.mode(
                            theme.primary,
                            BlendMode.srcIn,
                          ),
                          package: 'pack',
                        ),
                      ),
                      Icon(Icons.more_vert, color: Colors.white54),
                    ],
                  ),
                  Text(
                    info.title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  ProgressLine(
                    color: theme.primary,
                    percentage: info.percentage ,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${info.numOfServices} ",
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall!.copyWith(color: Colors.white70),
                      ),
                      Text(
                        info.subTitle!,
                        // info.totalStorage!,
                        style: TextStyle(color:theme.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProgressLine extends StatelessWidget {
  const ProgressLine({
    super.key,
    this.color = Colors.blue,
    required this.percentage,
  });

  final Color? color;
  final num? percentage;

  @override
  Widget build(BuildContext context) {
    var percent = percentage!.isNaN || percentage == 0  ? 100 :  percentage;
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 5,
          decoration: BoxDecoration(
            color: color!.withValues(alpha: 0.1),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        LayoutBuilder(
          builder:
              (context, constraints) => Container(
                width: constraints.maxWidth * (percent! / 100),
                height: 5,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
        ),
      ],
    );
  }
}
