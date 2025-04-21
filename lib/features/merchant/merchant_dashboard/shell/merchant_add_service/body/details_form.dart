// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../core/merchant_add_service_provider.dart';
// import 'other_components.dart';
//
// class DetailsForm extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<MerchantAddServiceProvider>(
//       builder: (context, provider, _) {
//         return Card(
//           elevation: 2,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Service Details',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 16),
//                 if (provider.maxDescriptionLength > 0) ...[
//                   FormLabel(label: 'Description (Max ${provider.maxDescriptionLength} characters)'),
//                   TextFormField(
//                     controller: provider.descriptionController,
//                     maxLength: provider.maxDescriptionLength,
//                     maxLines: 3,
//                     decoration: _inputDecoration('Enter service description'),
//                     onChanged: provider.setDescription,
//                     validator: (value) => value!.length > provider.maxDescriptionLength
//                         ? 'Exceeds ${provider.maxDescriptionLength} characters'
//                         : null,
//                   ),
//                   const SizedBox(height: 16),
//                 ],
//                 if (provider.canShowOffers) ...[
//                   FormLabel(label: 'Special Offers (Max ${provider.maxOfferLength} characters)'),
//                   TextFormField(
//                     controller: provider.offersController,
//                     maxLength: provider.maxOfferLength,
//                     maxLines: 2,
//                     decoration: _inputDecoration('Enter special offers or discounts'),
//                   ),
//                   const SizedBox(height: 16),
//                 ],
//                 FormLabel(label: 'Service Address'),
//                 TextFormField(
//                   controller: provider.addressController,
//                   decoration: _inputDecoration('Enter service address'),
//                 ),
//                 const SizedBox(height: 16),
//                 if (provider.canShowPhoneNumber)
//                   FormCheckbox(
//                     title: 'Show phone number',
//                     value: provider.showPhoneNumber,
//                     onChanged: (value) => provider.showPhoneNumber = value!,
//                   ),
//                 if (provider.featureManager?.canShowEmail ?? false)
//                   FormCheckbox(
//                     title: 'Enable chat',
//                     value: provider.enableChat,
//                     onChanged: (value) => provider.enableChat = value!,
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   InputDecoration _inputDecoration(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
//     );
//   }
// }