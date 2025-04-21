// import 'package:flutter/material.dart';
// import 'package:pack/ui/widgets/responsive.dart';
// import '../../../merchant_dashboard_shell.dart';
// import 'card_view_info.dart';
//
// import '../../../merchant_dashboard_shell.dart';
//
// import 'dashboard_card_items.dart';
//
// class MyFiles extends StatelessWidget {
//   const MyFiles({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final Size _size = MediaQuery.of(context).size;
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text("My Files", style: Theme.of(context).textTheme.titleMedium),
//             ElevatedButton.icon(
//               style: TextButton.styleFrom(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: 16 * 1.5,
//                   vertical: 16 / (Responsive.isMobile(context) ? 2 : 1),
//                 ),
//               ),
//               onPressed: () {},
//               icon: Icon(Icons.add),
//               label: Text("Add New"),
//             ),
//           ],
//         ),
//         SizedBox(height: 16),
//         Responsive(
//           mobile: FileInfoCardGridView(
//             crossAxisCount: _size.width < 650 ? 2 : 4,
//             childAspectRatio: _size.width < 650 ? 1.3 : 1,
//           ),
//           tablet: FileInfoCardGridView(),
//           desktop: FileInfoCardGridView(
//             childAspectRatio: _size.width < 1400 ? 1.1 : 1.4,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class FileInfoCardGridView extends StatelessWidget {
//   const FileInfoCardGridView({
//     super.key,
//     this.crossAxisCount = 4,
//     this.childAspectRatio = 1,
//   });
//
//   final int crossAxisCount;
//   final double childAspectRatio;
//
//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       physics: NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       itemCount: myGridFields.length,
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: crossAxisCount,
//         crossAxisSpacing: 16,
//         mainAxisSpacing: 16,
//         childAspectRatio: childAspectRatio,
//       ),
//       itemBuilder:
//           (context, index) => CardViewInfo(
//             info: myGridFields[index],
//             onTap: (BuildContext context) => myGridFields[index].onTap(context),
//           ),
//     );
//   }
// }
