import 'package:flutter/material.dart';
import 'package:pack/pack.dart';
import 'package:provider/provider.dart';
import '../models/chat_models.dart';
import '../services/chat_manager.dart';
import 'chat_screen.dart';

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key});

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final chatManager = Provider.of<ChatManager>(context, listen: false);
    setState(() {
      _isLoading = true;
    });
    
    await chatManager.refreshConversations();
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConversations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildConversationList(),
    );
  }

  Widget _buildConversationList() {
    return Consumer<ChatManager>(
      builder: (context, chatManager, child) {
        final conversations = chatManager.conversations;
        
        if (conversations.isEmpty) {
          return const Center(
            child: Text(
              'No conversations yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }
        
        return RefreshIndicator(
          onRefresh: _loadConversations,
          child: ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return _buildConversationTile(conversation);
            },
          ),
        );
      },
    );
  }

  Widget _buildConversationTile(Conversation conversation) {
    final chatManager = Provider.of<ChatManager>(context, listen: false);
    final userType = chatManager.userType;
    
    // Determine the other user's type and ID
    final otherUserType = userType == 'customer' ? 'merchant' : 'customer';
    final otherUserId = userType == 'customer' ? conversation.merchantId : conversation.customerId;
    
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: conversation.otherUserImage.isNotEmpty
            ? NetworkImage(conversation.otherUserImage)
            : null,
        child: conversation.otherUserImage.isEmpty
            ? Text(conversation.otherUserName[0].toUpperCase())
            : null,
      ),
      title: Text(
        conversation.otherUserName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        conversation.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            conversation.lastMessageTime.timeAgo,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (conversation.unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                conversation.unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversationId: conversation.id,
              otherUserName: conversation.otherUserName,
              otherUserImage: conversation.otherUserImage,
              otherUserType: otherUserType,
              otherUserId: otherUserId,
            ),
          ),
        ).then((_) {
          // Refresh the list when returning from chat screen
          _loadConversations();
        });
      },
    );
  }
}