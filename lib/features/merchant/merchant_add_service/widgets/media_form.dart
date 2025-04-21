import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../core/merchant_add_service_provider.dart';

class MediaForm extends StatelessWidget {
  const MediaForm({super.key});

  @override
  Widget build(BuildContext context) {
    final theme =  Theme.of(context).colorScheme;

    return Consumer<MerchantAddServiceProvider>(
      builder: (context, provider, _) {
        final maxPhotoCount = provider.maxPhotoCount;
        final isVideoAllowed = provider.isVideoAllowed;
        final maxVideoLength = provider.maxVideoLength;
        final servicePhotos = provider.servicePhotos;
        final videoPath = provider.videoPath;
        final isUploading = provider.isUploading;
        final uploadProgress = provider.uploadProgress;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Media',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  semanticsLabel: 'Media Form',
                ),
                const SizedBox(height: 16),

                // Photos Section
                if (maxPhotoCount > 0) ...[
                  _buildLabel('Photos', 'Max $maxPhotoCount photos'),
                  const SizedBox(height: 8),
                  if (servicePhotos.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1,
                          ),
                      itemCount: servicePhotos.length,
                      itemBuilder: (context, index) {
                        return _buildPhotoItem(
                          context,
                          servicePhotos[index],
                          () => provider.removeImage(index),
                        );
                      },
                    ),
                  if (servicePhotos.length < maxPhotoCount)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        color: CupertinoColors.systemGrey5,
                        borderRadius: BorderRadius.circular(8),
                        onPressed:
                            isUploading
                                ? null
                                : () =>
                                    _showImageSourcePicker(context, provider),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              CupertinoIcons.photo,
                              color: CupertinoColors.activeBlue,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Add Photo',
                              style: TextStyle(
                                color: CupertinoColors.activeBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],

                // Upload Progress
                if (isUploading)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Uploading... ${(uploadProgress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.activeBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: uploadProgress,
                          backgroundColor: CupertinoColors.systemGrey5,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            CupertinoColors.activeBlue,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Video Section
                if (isVideoAllowed) ...[
                  const SizedBox(height: 24),
                  _buildLabel('Video', 'Max $maxVideoLength seconds'),
                  const SizedBox(height: 8),
                  if (videoPath != null && videoPath.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: CupertinoColors.systemGrey4),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: CupertinoColors.activeBlue.withOpacity(
                                0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              CupertinoIcons.video_camera,
                              color: CupertinoColors.activeBlue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  path.basename(videoPath),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Video selected',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => provider.removeVideo(),
                            child: const Icon(
                              CupertinoIcons.clear_circled,
                              color: CupertinoColors.systemRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (videoPath == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        color: CupertinoColors.systemGrey5,
                        borderRadius: BorderRadius.circular(8),
                        onPressed:
                            isUploading
                                ? null
                                : () =>
                                    _showVideoSourcePicker(context, provider),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              CupertinoIcons.video_camera,
                              color: CupertinoColors.activeBlue,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Add Video',
                              style: TextStyle(
                                color: CupertinoColors.activeBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],

                // Navigation
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        color: CupertinoColors.systemGrey5,
                        borderRadius: BorderRadius.circular(8),
                        onPressed: () {
                          if (provider.currentStep == 0) {
                            provider.confirmExit(context);
                          } else {
                            provider.previousStep();
                          }
                        },
                        child: const Text(
                          'Previous',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        color: CupertinoColors.activeBlue,
                        borderRadius: BorderRadius.circular(8),
                        onPressed:
                            isUploading
                                ? null
                                : () => provider.nextStep(context),
                        child:   Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.surface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text, [String? helperText]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          if (helperText != null)
            Text(
              helperText,
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoItem(
    BuildContext context,
    String imageUrl,
    VoidCallback onRemove,
  ) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: CupertinoColors.systemGrey4),
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
              onError: (exception, stackTrace) {
                Provider.of<MerchantAddServiceProvider>(
                  context,
                  listen: false,
                ).removeImage(0);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to load image'),
                    backgroundColor: CupertinoColors.systemRed,
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: CupertinoColors.systemRed,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.clear,
                color: CupertinoColors.white,
                size: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showImageSourcePicker(
    BuildContext context,
    MerchantAddServiceProvider provider,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (context) => CupertinoActionSheet(
            title: const Text('Select Image Source'),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  provider.pickImage(ImageSource.camera, context);
                },
                child: const Text('Take Photo'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  provider.pickImage(ImageSource.gallery, context);
                },
                child: const Text('Choose from Gallery'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
    );
  }

  void _showVideoSourcePicker(
    BuildContext context,
    MerchantAddServiceProvider provider,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (context) => CupertinoActionSheet(
            title: const Text('Select Video Source'),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  provider.pickVideo(ImageSource.gallery, context);
                },
                child: const Text('Choose from Gallery'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
    );
  }
}
