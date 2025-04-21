// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../core/merchant_add_service_provider.dart';
// import 'other_components.dart';
//
// class MediaForm extends StatelessWidget {
//   const MediaForm({super.key});
//
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
//                   'Media Content',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 16),
//                 if (provider.maxPhotoCount > 0) ...[
//                   FormLabel(label: 'Service Photos (Max ${provider.maxPhotoCount})'),
//                   const SizedBox(height: 8),
//                   if (provider.servicePhotos.isNotEmpty)
//                     GridView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 3,
//                         crossAxisSpacing: 8,
//                         mainAxisSpacing: 8,
//                         childAspectRatio: 1,
//                       ),
//                       itemCount: provider.servicePhotos.length,
//                       itemBuilder: (context, index) => _buildPhotoTile(provider, index),
//                     ),
//                   const SizedBox(height: 16),
//                   if (provider.servicePhotos.length < provider.maxPhotoCount)
//                     Center(
//                       child: ElevatedButton.icon(
//                         onPressed: provider.isUploading ? null : () => provider.pickImage(context),
//                         icon: const Icon(Icons.add_photo_alternate),
//                         label: const Text('Add Photo'),
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                         ),
//                       ),
//                     ),
//                   const SizedBox(height: 24),
//                 ],
//                 if (provider.isVideoAllowed) ...[
//                   FormLabel(label: 'Video (Max ${provider.maxVideoLength} seconds)'),
//                   if (provider.videoPath != null)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 8.0),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               provider.videoPath!.split('/').last,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.clear),
//                             onPressed: () {
//                               provider.pickVideo(context);
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   Center(
//                     child: ElevatedButton.icon(
//                       onPressed: provider.isUploading ? null : () => provider.pickVideo(context),
//                       icon: const Icon(Icons.video_library),
//                       label: const Text('Select Video'),
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     'Note: Select a video from your gallery.',
//                     style: TextStyle(fontSize: 12, color: Colors.grey),
//                   ),
//                 ],
//                 if (provider.isUploading)
//                   const Padding(
//                     padding: EdgeInsets.only(top: 16.0),
//                     child: Center(child: CircularProgressIndicator()),
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildPhotoTile(MerchantAddServiceProvider provider, int index) {
//     return Stack(
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: Colors.grey.shade300),
//             image: DecorationImage(
//               image: FileImage(provider.servicePhotos[index]),
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//         Positioned(
//           top: 0,
//           right: 0,
//           child: InkWell(
//             onTap: () => provider.removePhoto(index),
//             child: Container(
//               padding: const EdgeInsets.all(4),
//               decoration: const BoxDecoration(
//                 color: Colors.red,
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.close, color: Colors.white, size: 16),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }