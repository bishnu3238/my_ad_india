import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_ad/features/merchant/merchant_dashboard/shell/dashboard/core/merchant_dashboard_provider.dart';
import 'package:my_ad/utils/widgets/svg_icon_widget.dart';
import 'package:pack/pack.dart';
import 'package:provider/provider.dart';

import '../../../merchant_dashboard_shell.dart';

class RecentInquiry extends StatelessWidget {
  const RecentInquiry({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent Inquiry",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Consumer<DashboardProvider>(
            builder: (context, provider, _) {
              return SizedBox(
                width: double.infinity,
                child: DataTable(
                  columnSpacing: 5,

                  // minWidth: 600,
                  columns: [
                    DataColumn(label: Text("Customer Name")),
                    DataColumn(label: Text("Date")),
                    DataColumn(label: Text("for")),
                  ],
                  rows: List.generate(
                    provider.visits.length > 10 ? 10 : provider.visits.length,

                    (index) => DataRow(
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              SvgIconWidget(
                                iconPath: SvgIcons.profileIcon,
                                height: 20,
                                width: 20,
                                package: 'pack',
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                child: ResponsiveText(
                                  text:
                                      provider.visits[index].customer.username,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Text(
                            provider.visits[index].dated.toDateTime()!.toDMY,
                            maxLines: 1,
                          ),
                        ),
                        DataCell(
                          Text(
                            provider.visits[index].message,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
