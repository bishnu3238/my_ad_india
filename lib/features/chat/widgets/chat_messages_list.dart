import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';
import 'message_bubble.dart';

class ChatMessagesList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final String currentUserId;
  final bool isSelectionMode;
  final Set<String> selectedMessageIds;
  final Function(String)? onMessageTap;
  final Function(String) onMessageLongPress;
  final VoidCallback onLoadMore;
  final bool isLoadingMore;
  final bool hasMoreMessages;

  const ChatMessagesList({
    Key? key,
    required this.messages,
    required this.scrollController,
    required this.currentUserId,
    this.isSelectionMode = false,
    required this.selectedMessageIds,
    this.onMessageTap,
    required this.onMessageLongPress,
    required this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMoreMessages = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(
        child: Text(
          'No messages yet. Start the conversation!',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            hasMoreMessages &&
            !isLoadingMore) {
          onLoadMore();
        }
        return false;
      },
      child: ListView.builder(
        controller: scrollController,
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: messages.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (isLoadingMore && index == 0) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          final messageIndex = isLoadingMore ? index - 1 : index;
          final message = messages[messageIndex];
          final isCurrentUser = message.senderId == currentUserId;
          final showDate = _shouldShowDate(messageIndex);
          
          return Column(
            children: [
              if (showDate) _buildDateSeparator(context, message.timestamp),
              InkWell(
                onTap: onMessageTap != null
                    ? () => onMessageTap!(message.id)
                    : null,
                onLongPress: () => onMessageLongPress(message.id),
                child: MessageBubble(
                  message: message,
                  isCurrentUser: isCurrentUser,
                  isSelected: selectedMessageIds.contains(message.id),
                  isSelectionMode: isSelectionMode,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _shouldShowDate(int index) {
    if (index == messages.length - 1) {
      return true;
    }

    final currentMessage = messages[index];
    final previousMessage = messages[index + 1];

    final currentDate = DateTime(
      currentMessage.timestamp.year,
      currentMessage.timestamp.month,
      currentMessage.timestamp.day,
    );

    final previousDate = DateTime(
      previousMessage.timestamp.year,
      previousMessage.timestamp.month,
      previousMessage.timestamp.day,
    );

    return currentDate.isAfter(previousDate);
  }

  Widget _buildDateSeparator(BuildContext context, DateTime date) {
    String dateText;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      dateText = 'Today';
    } else if (messageDate == yesterday) {
      dateText = 'Yesterday';
    } else {
      dateText = DateFormat('MMMM d, y').format(date);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(
            child: Divider(thickness: 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              dateText,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Expanded(
            child: Divider(thickness: 1),
          ),
        ],
      ),
    );
  }
}
