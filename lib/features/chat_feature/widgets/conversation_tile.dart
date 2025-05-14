import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/message_formater.dart';

class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback? onTap;

  const ConversationTile({
    Key? key,
    required this.conversation,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: conversation.merchantImage != null
            ? NetworkImage(conversation.merchantImage!)
            : null,
        child: conversation.merchantImage == null ? Icon(Icons.person) : null,
      ),
      title: Text(conversation.merchantName ?? ''),
      subtitle: Text(
        conversation.lastMessage != null
            ? MessageFormatter.formatMessagePreview(
          // You may need to adapt this if you have a Message object
          // Here, just show the last message string
          Message.empty.copyWith(message: conversation.lastMessage ?? ''),
        )
            : '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: conversation.unreadCount != null && conversation.unreadCount! > 0
          ? CircleAvatar(
        radius: 10,
        backgroundColor: Colors.red,
        child: Text(
          '${conversation.unreadCount}',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      )
          : null,
      onTap: onTap,
    );
  }
}
