import 'package:flutter/material.dart';
import 'package:pack/constant/constant.dart';
import 'package:provider/provider.dart';
 import '../core/chat_state.dart';
import '../core/chat_viewmodel.dart';
import '../models/chat_conversation.dart';
import 'chat_screen.dart';

class ChatConversationsScreen extends StatefulWidget {
  final String userId;

  const ChatConversationsScreen({Key? key, required this.userId})
    : super(key: key);

  @override
  State<ChatConversationsScreen> createState() =>
      _ChatConversationsScreenState();
}

class _ChatConversationsScreenState extends State<ChatConversationsScreen> {
  late ChatViewModel _viewModel;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<ChatViewModel>(context, listen: false);
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    if (!_isInitialized) {
      await _viewModel.initialize(widget.userId);
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search dialog
              showSearch(
                context: context,
                delegate: _ConversationSearchDelegate(
                  viewModel: _viewModel,
                  userId: widget.userId,
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ChatViewModel>(
        builder: (context, viewModel, _) {
          final state = viewModel.state;

          if (state.viewState == ChatViewState.loading &&
              state.conversations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start chatting with merchants',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: viewModel.refreshConversations,
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 8),
              itemCount: state.conversations.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final conversation = state.conversations[index];
                return _ConversationItem(
                  conversation: conversation,
                  userId: widget.userId,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ConversationItem extends StatelessWidget {
  final ChatConversation conversation;
  final String userId;

  const _ConversationItem({
    Key? key,
    required this.conversation,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ChatScreen(
                  merchantId: conversation.merchantId,
                  merchantName: conversation.merchantName,
                  userId: userId,
                ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Merchant avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child:
                  conversation.merchantAvatar != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.network(
                          conversation.merchantAvatar!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Icon(
                                Icons.business,
                                size: 28,
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                      )
                      : Icon(
                        Icons.business,
                        size: 28,
                        color: Theme.of(context).primaryColor,
                      ),
            ),
            const SizedBox(width: 16),
            // Conversation details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Merchant name
                      Expanded(
                        child: Text(
                          conversation.merchantName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Last message time
                      Text(
                        conversation.lastMessageTime.timeAgo,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Last message
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage ?? 'Start a conversation',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            conversation.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationSearchDelegate extends SearchDelegate<String> {
  final ChatViewModel viewModel;
  final String userId;

  _ConversationSearchDelegate({required this.viewModel, required this.userId});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Text(
          'Search for conversations',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    final filteredConversations =
        viewModel.state.conversations.where((conversation) {
          return conversation.merchantName.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              (conversation.lastMessage?.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ??
                  false);
        }).toList();

    if (filteredConversations.isEmpty) {
      return Center(
        child: Text(
          'No conversations found for "$query"',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: 8),
      itemCount: filteredConversations.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final conversation = filteredConversations[index];
        return _ConversationItem(conversation: conversation, userId: userId);
      },
    );
  }
}
