import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/provider/chat_list_provider.dart';
import 'core/chat_list_state.dart';
import '../../models/models.dart';

class ChatListScreen extends StatefulWidget {
  final String userType;
  final int userId;
  final void Function(Conversation conversation)? onChatTap;

  const ChatListScreen({
    super.key,
    required this.userType,
    required this.userId,
    this.onChatTap,
  });

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late ChatListProvider provider;
  String _search = '';

  @override
  void initState() {
    super.initState();
    provider = Provider.of<ChatListProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dev.log('Loading conversations: ${widget.userType}, ${widget.userId}');
      provider.loadConversations(
        userType: widget.userType,
        userId: widget.userId,
      );
    });
  }

  Future<void> _onRefresh() async {
    await provider.refresh(userType: widget.userType, userId: widget.userId);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Chat list refreshed')));
  }

  void _onDelete(Conversation conversation) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Delete Chat'),
            content: Text('Are you sure you want to delete this chat?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Delete'),
              ),
            ],
          ),
    );
    if (confirm == true) {
      await provider.deleteConversation(conversation.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Chat deleted')));
    }
  }

  void _onArchive(Conversation conversation) async {
    await provider.archiveConversation(conversation.id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Chat archived')));
  }

  void _onMarkAsRead(Conversation conversation) {
    // Mark this conversation as read in UI only
    provider.markAllAsRead();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Marked as read')));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatListProvider>(
      builder: (context, chatList, _) {
        final state = chatList.state;
        final filtered =
            _search.isEmpty
                ? state.conversations
                : state.conversations
                    .where(
                      (c) =>
                          (c.merchantName ?? '').toLowerCase().contains(
                            _search.toLowerCase(),
                          ) ||
                          (c.lastMessage ?? '').toLowerCase().contains(
                            _search.toLowerCase(),
                          ),
                    )
                    .toList();

        return Scaffold(
          appBar: AppBar(
            title: Text('Chats'),
            actions: [
              if (state.unreadCount > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Chip(
                    label: Text('${state.unreadCount} unread'),
                    backgroundColor: Colors.red[100],
                  ),
                ),
              IconButton(
                icon: Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed:
                    () => chatList.refresh(
                      userType: widget.userType,
                      userId: widget.userId,
                    ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(48),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search chats...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: (val) => setState(() => _search = val),
                ),
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: _onRefresh,
            child: Builder(
              builder: (context) {
                if (state.status == ChatListStatus.loading ||
                    state.status == ChatListStatus.refreshing) {
                  return Center(child: CircularProgressIndicator());
                }
                if (state.status == ChatListStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 40),
                        SizedBox(height: 8),
                        Text(
                          'Failed to load chats',
                          style: TextStyle(color: Colors.red),
                        ),
                        if (state.error != null)
                          Text(state.error!, style: TextStyle(fontSize: 12)),
                        SizedBox(height: 12),
                        ElevatedButton.icon(
                          icon: Icon(Icons.refresh),
                          onPressed:
                              () => chatList.loadConversations(
                                userType: widget.userType,
                                userId: widget.userId,
                              ),
                          label: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text('No conversations found'),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final convo = filtered[idx];
                    return Dismissible(
                      key: ValueKey(convo.id),
                      background: Container(
                        color: Colors.blue[100],
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 24),
                        child: Icon(Icons.archive, color: Colors.blue),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red[100],
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 24),
                        child: Icon(Icons.delete, color: Colors.red),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          _onArchive(convo);
                          return false;
                        } else {
                          _onDelete(convo);
                          return false;
                        }
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              convo.merchantImage != null
                                  ? NetworkImage(convo.merchantImage!)
                                  : null,
                          child:
                              convo.merchantImage == null
                                  ? Icon(Icons.person)
                                  : null,
                        ),
                        title: Text(
                          widget.userType == 'merchant'
                              ? convo.customerName ?? 'Customer'
                              : convo.merchantName ?? 'Merchant',
                        ),
                        subtitle: Text(convo.lastMessage ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if ((convo.unreadCount ?? 0) > 0)
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: Text(
                                  '${convo.unreadCount}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'delete') _onDelete(convo);
                                if (value == 'archive') _onArchive(convo);
                                if (value == 'mark_read') _onMarkAsRead(convo);
                              },
                              itemBuilder:
                                  (ctx) => [
                                    PopupMenuItem(
                                      value: 'archive',
                                      child: Text('Archive'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                    PopupMenuItem(
                                      value: 'mark_read',
                                      child: Text('Mark as read'),
                                    ),
                                  ],
                            ),
                          ],
                        ),
                        onTap: () => widget.onChatTap?.call(convo),
                        onLongPress: () => _onMarkAsRead(convo),
                        visualDensity: VisualDensity.compact,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        tileColor: Theme.of(context).cardColor,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
