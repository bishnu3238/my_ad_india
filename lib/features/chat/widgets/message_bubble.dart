import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isCurrentUser;
  final bool isSelected;
  final bool isSelectionMode;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.isSelected = false,
    this.isSelectionMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser && isSelectionMode)
            _buildSelectionIndicator(context),
          
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: _getBubbleColor(context),
                borderRadius: _getBubbleRadius(),
                border: message.isDeleted 
                    ? Border.all(color: Colors.grey.shade300)
                    : null,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: _buildMessageContent(context),
            ),
          ),
          
          if (isCurrentUser && isSelectionMode)
            _buildSelectionIndicator(context),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    if (message.isDeleted) {
      return _buildDeletedMessage(context);
    }

    switch (message.type) {
      case MessageType.text:
        return _buildTextMessage(context);
      case MessageType.image:
        return _buildImageMessage(context);
      case MessageType.audio:
        return _buildAudioMessage(context);
      case MessageType.video:
        return _buildVideoMessage(context);
      case MessageType.document:
        return _buildFileMessage(context);
      case MessageType.location:
        return _buildLocationMessage(context);
      default:
        return _buildTextMessage(context);
    }
  }

  Widget _buildDeletedMessage(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.not_interested,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          'This message was deleted',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          DateFormat('HH:mm').format(message.timestamp),
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildTextMessage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          message.content,
          style: TextStyle(
            color: isCurrentUser ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isCurrentUser ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
            if (isCurrentUser) const SizedBox(width: 4),
            if (isCurrentUser) _buildMessageStatus(),
          ],
        ),
      ],
    );
  }

  Widget _buildImageMessage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: GestureDetector(
            onTap: () {
              // Show full-screen image
              _showFullScreenImage(context);
            },
            child: Image.network(
              message.content,
              fit: BoxFit.cover,
              width: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.error),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isCurrentUser ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
            if (isCurrentUser) const SizedBox(width: 4),
            if (isCurrentUser) _buildMessageStatus(),
          ],
        ),
      ],
    );
  }

  Widget _buildAudioMessage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_circle_fill,
              color: isCurrentUser ? Colors.white : Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                  color: isCurrentUser 
                      ? Colors.white.withOpacity(0.2) 
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      LinearProgressIndicator(
                        value: 0.0, // This would be controlled by audio player
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCurrentUser 
                              ? Colors.white.withOpacity(0.5) 
                              : Theme.of(context).primaryColor.withOpacity(0.5),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '0:00', // This would be controlled by audio player
                              style: TextStyle(
                                fontSize: 12,
                                color: isCurrentUser ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              '1:30', // This would be the total duration
                              style: TextStyle(
                                fontSize: 12,
                                color: isCurrentUser ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isCurrentUser ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
            if (isCurrentUser) const SizedBox(width: 4),
            if (isCurrentUser) _buildMessageStatus(),
          ],
        ),
      ],
    );
  }

  Widget _buildVideoMessage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                message.metadata?['thumbnail'] ?? '',
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.video_file),
                    ),
                  );
                },
              ),
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isCurrentUser ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
            if (isCurrentUser) const SizedBox(width: 4),
            if (isCurrentUser) _buildMessageStatus(),
          ],
        ),
      ],
    );
  }

  Widget _buildFileMessage(BuildContext context) {
    final fileName = message.metadata?['fileName'] ?? 'File';
    final fileSize = message.metadata?['fileSize'] ?? '0 KB';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCurrentUser 
                ? Colors.white.withOpacity(0.2) 
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.insert_drive_file,
                color: isCurrentUser ? Colors.white : Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: TextStyle(
                        color: isCurrentUser ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      fileSize,
                      style: TextStyle(
                        fontSize: 12,
                        color: isCurrentUser ? Colors.white70 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.download,
                color: isCurrentUser ? Colors.white : Theme.of(context).primaryColor,
                size: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isCurrentUser ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
            if (isCurrentUser) const SizedBox(width: 4),
            if (isCurrentUser) _buildMessageStatus(),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationMessage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Image.network(
                'https://maps.googleapis.com/maps/api/staticmap?center=${message.metadata?['latitude']},${message.metadata?['longitude']}&zoom=15&size=300x200&markers=color:red%7C${message.metadata?['latitude']},${message.metadata?['longitude']}&key=YOUR_API_KEY',
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.location_on, size: 50),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.black.withOpacity(0.5),
                  child: Text(
                    message.metadata?['address'] ?? 'Location',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isCurrentUser ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
            if (isCurrentUser) const SizedBox(width: 4),
            if (isCurrentUser) _buildMessageStatus(),
          ],
        ),
      ],
    );
  }

  Widget _buildMessageStatus() {
    IconData icon;
    Color color;

    switch (message.status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        color = Colors.white70;
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.white70;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.white70;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.blue.shade300;
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = Colors.red.shade300;
        break;
      default:
        icon = Icons.check;
        color = Colors.white70;
    }

    return Icon(
      icon,
      size: 12,
      color: color,
    );
  }

  Widget _buildSelectionIndicator(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Icon(
        isSelected ? Icons.check_circle : Icons.circle_outlined,
        size: 20,
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
      ),
    );
  }

  Color _getBubbleColor(BuildContext context) {
    if (message.isDeleted) {
      return Colors.grey.shade100;
    }
    
    return isCurrentUser
        ? Theme.of(context).primaryColor
        : Colors.grey.shade200;
  }

  BorderRadius _getBubbleRadius() {
    return BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
      bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
    );
  }

  void _showFullScreenImage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 3,
              child: Image.network(
                message.content,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
