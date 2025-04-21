// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:pack/pack.dart';
// import 'package:provider/provider.dart';
// import '../core/merchant_add_service_provider.dart';
//
// class ReviewForm extends StatelessWidget {
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
//                   'Review Service Details',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 16),
//                 _buildReviewItem('Service Name', provider.serviceNameController.text),
//                 _buildReviewItem('Category', provider.selectedCategory),
//                 _buildReviewItem('Subcategory', provider.selectedSubCategory),
//                 _buildReviewItem('Service Type', provider.selectedService),
//                 _buildReviewItem('Rate', '${Currency.rupeeSymbol}${provider.rateController.text}'),
//                 if (provider.descriptionController.text.isNotEmpty)
//                   _buildReviewItem('Description', provider.descriptionController.text),
//                 if (provider.offersController.text.isNotEmpty)
//                   _buildReviewItem('Offers', provider.offersController.text),
//                 if (provider.addressController.text.isNotEmpty)
//                   _buildReviewItem('Address', provider.addressController.text),
//                 _buildReviewItem('Show Phone Number', provider.showPhoneNumber ? 'Yes' : 'No'),
//                 _buildReviewItem('Enable Chat', provider.enableChat ? 'Yes' : 'No'),
//                 if (provider.servicePhotos.isNotEmpty)
//                   _buildReviewItem('Photos', '${provider.servicePhotos.length} photos added'),
//                 if (provider.videoPath != null)
//                   _buildReviewItem('Video', provider.videoPath!.split('/').last),
//                 const SizedBox(height: 16),
//                 _buildPlanLimits(provider),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildReviewItem(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
//           ),
//           Expanded(child: Text(value)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPlanLimits(MerchantAddServiceProvider provider) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.blue.shade50,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.blue.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Plan Limits', style: TextStyle(fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           Text('Remaining Services: ${provider.featureManager?.remainingServices ?? 0}'),
//           Text('Remaining Updates: ${provider.featureManager?.remainingUpdates ?? 0}'),
//           Text('Subscription Valid Until: ${provider.planAccess?.validUntil.toString().split(' ')[0] ?? 'Unknown'}'),
//         ],
//       ),
//     );
//   }
// }