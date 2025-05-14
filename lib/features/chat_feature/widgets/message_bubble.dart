import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/message_formater.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onLongPress,
  });

  Widget _buildContent(BuildContext context) {
    // Image
    if (message.messageType == 'image' && message.fileUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          message.fileUrl!,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) => Container(
                width: 200,
                height: 200,
                color: Colors.grey[300],
                child: Icon(Icons.broken_image, size: 48),
              ),
        ),
      );
    }
    // Video
    if (message.messageType == 'video' && message.fileUrl != null) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.videocam, color: Colors.white, size: 48),
          ),
          Icon(Icons.play_circle_fill, color: Colors.white, size: 56),
        ],
      );
    }
    // Audio
    if (message.messageType == 'audio' && message.fileUrl != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.audiotrack, color: Colors.blue),
          SizedBox(width: 8),
          Text('Audio message', style: TextStyle(color: Colors.blue)),
        ],
      );
    }
    // Document/File
    if (message.messageType == 'file' && message.fileUrl != null) {
      final fileName = message.fileUrl!.split('/').last;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insert_drive_file, color: Colors.green),
          SizedBox(width: 8),
          Flexible(
            child: GestureDetector(
              onTap: () {
                // TODO: Implement file open/download logic
              },
              child: Text(
                fileName,
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.blue,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      );
    }
    // Location
    if (message.messageType == 'location') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on, color: Colors.red),
          SizedBox(width: 8),
          Text('Location shared', style: TextStyle(color: Colors.red)),
        ],
      );
    }
    // Text
    return Text(message.message);
  }

  Widget _buildStatusIcon(BuildContext context) {
    // You may want to use your own logic for sent/delivered/read
    if (!isMe) return SizedBox.shrink();
    // Example: isRead -> double blue tick, else single/double grey tick
    if (message.isRead) {
      return Icon(Icons.done_all, size: 16, color: Colors.blue);
    } else {
      return Icon(Icons.done_all, size: 16, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isMe ? Colors.blue[100] : Colors.grey[200];
    final align = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
      bottomLeft: isMe ? Radius.circular(12) : Radius.circular(0),
      bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
    );
    return Align(
      alignment: align,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: borderRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [_buildContent(context), SizedBox(height: 4)],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  MessageFormatter.formatMessageTime(message.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                SizedBox(width: 4),
                _buildStatusIcon(context),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
