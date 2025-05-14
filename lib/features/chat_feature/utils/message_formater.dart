import 'package:intl/intl.dart';
import '../models/message.dart';

class MessageFormatter {
  // Format message timestamp
  static String formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      // Today, show time only
      return DateFormat.jm().format(timestamp);
    } else if (messageDate == yesterday) {
      // Yesterday
      return 'Yesterday, ${DateFormat.jm().format(timestamp)}';
    } else if (now.difference(timestamp).inDays < 7) {
      // Within a week, show day name
      return '${DateFormat.E().format(timestamp)}, ${DateFormat.jm().format(timestamp)}';
    } else {
      // Older, show date
      return DateFormat.yMMMd().format(timestamp);
    }
  }

  // Format message preview (for conversation list)
  static String formatMessagePreview(Message message, {int maxLength = 40}) {
    String preview = '';

    switch (message.messageType) {
      case MessageType.text:
        preview = message.message;
        break;
      case MessageType.image:
        preview = '📷 Image';
        if (message.message.isNotEmpty) {
          preview += ': ${message.message}';
        }
        break;
      case MessageType.video:
        preview = '🎥 Video';
        if (message.message.isNotEmpty) {
          preview += ': ${message.message}';
        }
        break;
      case MessageType.audio:
        preview = '🎵 Audio message';
        break;
      case MessageType.document:
        preview = '📎 File';
        if (message.message.isNotEmpty) {
          preview += ': ${message.message}';
        }
        break;
      case MessageType.location:
        preview = '📍 Location';
        break;
    }

    // Truncate if too long
    if (preview.length > maxLength) {
      preview = '${preview.substring(0, maxLength)}...';
    }

    return preview;
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      final kb = (bytes / 1024).toStringAsFixed(1);
      return '$kb KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      final mb = (bytes / (1024 * 1024)).toStringAsFixed(1);
      return '$mb MB';
    } else {
      final gb = (bytes / (1024 * 1024 * 1024)).toStringAsFixed(1);
      return '$gb GB';
    }
  }

  // Format call duration
  static String formatCallDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  // Get message status text
  static String getMessageStatusText(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return 'Sending...';
      case MessageStatus.sent:
        return 'Sent';
      case MessageStatus.delivered:
        return 'Delivered';
      case MessageStatus.read:
        return 'Read';
      case MessageStatus.failed:
        return 'Failed';
    }
  }

  // Format last seen time
  static String formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) {
      return 'Last seen: Unknown';
    }

    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inSeconds < 60) {
      return 'Last seen just now';
    } else if (difference.inMinutes < 60) {
      return 'Last seen ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return 'Last seen ${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return 'Last seen ${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return 'Last seen on ${DateFormat.yMMMd().format(lastSeen)}';
    }
  }
}
