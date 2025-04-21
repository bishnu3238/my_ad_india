// import 'package:flutter/material.dart';
// import 'package:my_ad/utils/widgets/svg_icon_widget.dart';
// import 'package:pack/pack.dart';
// import 'package:provider/provider.dart';
// import '../core/merchant_add_service_provider.dart';
// import 'service_limit_warning.dart';
//
// class HeaderCard extends StatelessWidget {
//   const HeaderCard({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<MerchantAddServiceProvider>(
//       builder: (context, provider, _) {
//         return Card(
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     const Icon(Icons.add_business, color: Colors.blue),
//                     const SizedBox(width: 8),
//                     const Text(
//                       'Add New Service',
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const Spacer(),
//                     IconButton(
//                       icon: const Icon(Icons.refresh),
//                       onPressed: provider.initial,
//                       tooltip: 'Refresh plan access',
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   "Let's get started! Tell us about your service.",
//                   style: TextStyle(fontSize: 12, color: Colors.black87),
//                 ),
//                 if (!provider.canAddMoreServices) ServiceLimitWarning(),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
