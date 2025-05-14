import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pack/pack.dart';
import '../models/models.dart';

class AttachmentPreview extends StatelessWidget {
  final Attachment attachment;
  final bool isMe;
  final VoidCallback? onTap;

  const AttachmentPreview({
    super.key,
    required this.attachment,
    this.isMe = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (attachment.isImage) {
      return _buildImagePreview(context);
    } else if (attachment.isVideo) {
      return _buildVideoPreview(context);
    } else if (attachment.isAudio) {
      return _buildAudioPreview(context);
    } else {
      return _buildFilePreview(context);
    }
  }

  Widget _buildImagePreview(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: attachment.fileUrl,
          placeholder:
              (context, url) => Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
          errorWidget:
              (context, url, error) => Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.error)),
              ),
          fit: BoxFit.cover,
          height: 200,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildVideoPreview(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video thumbnail
            if (attachment.thumbnailUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: attachment.thumbnailUrl!,
                  placeholder:
                      (context, url) => Container(color: Colors.grey[800]),
                  errorWidget:
                      (context, url, error) =>
                          Container(color: Colors.grey[800]),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),

            // Play button
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 32,
              ),
            ),

            // Duration
            if (attachment.metadata != null &&
                attachment.metadata!.containsKey('duration'))
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    attachment.metadata!['duration'],
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPreview(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isMe
                  ? Colors.blue.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.audiotrack,
              color: isMe ? Colors.blue : Colors.grey[700],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.fileName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isMe ? Colors.blue : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!attachment.fileSize.isNaN)
                    Text(
                      attachment.formattedFileSize,
                      style: TextStyle(
                        fontSize: 12,
                        color: isMe ? Colors.blue[700] : Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.play_circle_filled,
              color: isMe ? Colors.blue : Colors.grey[700],
              size: 36,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(BuildContext context) {
    IconData fileIcon;
    Color fileColor;

    // Determine file icon based on extension
    final extension = attachment.fileExtension?.toLowerCase() ?? '';

    if (['pdf'].contains(extension)) {
      fileIcon = Icons.picture_as_pdf;
      fileColor = Colors.red;
    } else if (['doc', 'docx'].contains(extension)) {
      fileIcon = Icons.description;
      fileColor = Colors.blue;
    } else if (['xls', 'xlsx'].contains(extension)) {
      fileIcon = Icons.table_chart;
      fileColor = Colors.green;
    } else if (['ppt', 'pptx'].contains(extension)) {
      fileIcon = Icons.slideshow;
      fileColor = Colors.orange;
    } else if (['zip', 'rar', '7z'].contains(extension)) {
      fileIcon = Icons.archive;
      fileColor = Colors.brown;
    } else {
      fileIcon = Icons.insert_drive_file;
      fileColor = Colors.grey;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isMe
                  ? Colors.blue.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(fileIcon, color: fileColor, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.fileName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isMe ? Colors.blue : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      if (attachment.fileExtension != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: fileColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            attachment.fileExtension!.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              color: fileColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (!attachment.fileSize.isNaN)
                        Text(
                          attachment.formattedFileSize,
                          style: TextStyle(
                            fontSize: 12,
                            color: isMe ? Colors.blue[700] : Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.download, color: isMe ? Colors.blue : Colors.grey[700]),
          ],
        ),
      ),
    );
  }
}

// Widget for displaying a local file before sending
class AttachmentPreviewBeforeSend extends StatelessWidget {
  final File file;
  final String fileName;
  final VoidCallback? onRemove;

  const AttachmentPreviewBeforeSend({
    Key? key,
    required this.file,
    required this.fileName,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final extension = fileName.split('.').last.toLowerCase();

    // Check if it's an image
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      return _buildImagePreview(context);
    }
    // Check if it's a video
    else if (['mp4', 'mov', 'avi', 'mkv'].contains(extension)) {
      return _buildVideoPreview(context);
    }
    // Otherwise treat as a file
    else {
      return _buildFilePreview(context, extension);
    }
  }

  Widget _buildImagePreview(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(file, height: 80, width: 80, fit: BoxFit.cover),
        ),
        if (onRemove != null)
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoPreview(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(
              Icons.play_circle_filled,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        if (onRemove != null)
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilePreview(BuildContext context, String extension) {
    IconData fileIcon;
    Color fileColor;

    // Determine file icon based on extension
    if (['pdf'].contains(extension)) {
      fileIcon = Icons.picture_as_pdf;
      fileColor = Colors.red;
    } else if (['doc', 'docx'].contains(extension)) {
      fileIcon = Icons.description;
      fileColor = Colors.blue;
    } else if (['xls', 'xlsx'].contains(extension)) {
      fileIcon = Icons.table_chart;
      fileColor = Colors.green;
    } else if (['ppt', 'pptx'].contains(extension)) {
      fileIcon = Icons.slideshow;
      fileColor = Colors.orange;
    } else if (['zip', 'rar', '7z'].contains(extension)) {
      fileIcon = Icons.archive;
      fileColor = Colors.brown;
    } else {
      fileIcon = Icons.insert_drive_file;
      fileColor = Colors.grey;
    }

    return Stack(
      children: [
        Container(
          height: 80,
          width: 80,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(fileIcon, color: fileColor, size: 32),
              const SizedBox(height: 4),
              Text(
                extension.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: fileColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (onRemove != null)
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
      ],
    );
  }
}
