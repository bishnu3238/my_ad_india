// import 'package:flutter/material.dart';
// import 'package:my_ad/features/merchant/merchant_add_service/core/merchant_add_service_provider.dart';
// import 'package:provider/provider.dart';
// import 'body/add_service_app_bar.dart';
// import 'body/service_form.dart';
//
// class MerchantAddServiceScreen extends StatelessWidget {
//   const MerchantAddServiceScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AddServiceAppBar(),
//       body: Consumer<MerchantAddServiceProvider>(
//         builder: (context, provider, _) {
//           if (provider.errorMessage != null) {
//             return Center(child: Text(provider.errorMessage!));
//           }
//           if (provider.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!provider.canAddMoreServices) {
//             return const Center(
//               child: Text(
//                 'You have reached the maximum number of services you can add.',
//               ),
//             );
//           }
//           return const ServiceForm();
//         },
//       ),
//     );
//   }
// }
