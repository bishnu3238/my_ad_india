// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'basic_info_form.dart';
// import 'details_form.dart';
// import 'media_form.dart';
// import 'review_form.dart';
// import 'header_card.dart';
// import 'progress_indicator.dart';
// import '../core/merchant_add_service_provider.dart';
// import 'package:my_ad/utils/widgets/primary_button.dart';
//
// class ServiceForm extends StatelessWidget {
//   const ServiceForm({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Consumer<MerchantAddServiceProvider>(
//         builder: (context, provider, _) {
//           return Form(
//             key: provider.formKey ?? GlobalKey<FormState>(),
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   HeaderCard(),
//                   const SizedBox(height: 20),
//                   ImprovedProgressIndicator(currentStep: provider.currentStep),
//                   const SizedBox(height: 20),
//                   _buildStepContent(provider),
//                   const SizedBox(height: 20),
//                   _buildNavigationButtons(context, provider),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildStepContent(MerchantAddServiceProvider provider) {
//     switch (provider.currentStep) {
//       case 0:
//         return BasicInfoForm();
//       case 1:
//         return DetailsForm();
//       case 2:
//         return MediaForm();
//       case 3:
//         return ReviewForm();
//       default:
//         return Container();
//     }
//   }
//
//   Widget _buildNavigationButtons(BuildContext context, MerchantAddServiceProvider provider) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         if (provider.currentStep > 0)
//           SizedBox(
//             width: 120,
//             child: OutlinedButton(
//               onPressed: provider.previousStep,
//               child: const Text('Previous'),
//             ),
//           )
//         else
//           const SizedBox(width: 120),
//         provider.currentStep < 3
//             ? PrimaryButton(
//           text: 'Next',
//           width: 120,
//           onPressed: provider.nextStep,
//         )
//             : PrimaryButton(
//           text: 'Submit',
//           width: 120,
//           onPressed: () => provider.submitService(context),
//         ),
//       ],
//     );
//   }
// }