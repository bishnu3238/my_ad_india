import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_ad/utils/widgets/svg_icon_widget.dart';
import 'package:pack/pack.dart';
import 'dashboard_card_items.dart';

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
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: 16,
              // minWidth: 600,
              columns: [
                DataColumn(label: Text("Customer Name")),
                DataColumn(label: Text("Date")),
                DataColumn(label: Text("for")),
              ],
              rows: List.generate(
                1,
                // demoRecentFiles.length > 10
                //     ? demoRecentFiles.length
                //     : 1,
                (index) => recentFileDataRow(demoRecentFiles[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

DataRow recentFileDataRow(RecentFile fileInfo) {
  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            SvgIconWidget(
              iconPath: SvgIcons.profileIcon,
              height: 30,
              width: 30,
              package: 'pack',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: ResponsiveText(
                text: fileInfo.title!,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      DataCell(Text(fileInfo.date!)),
      DataCell(Text(fileInfo.size!)),
    ],
  );
}
