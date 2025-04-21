import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../core/chat_state.dart';
import '../core/chat_viewmodel.dart';
import '../models/chat_conversation.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_messages_list.dart';
import '../widgets/connection_status_bar.dart';
import '../widgets/empty_chat_view.dart';
import '../widgets/loading_indicator.dart';

class ChatScreen extends StatefulWidget {
  final String merchantId;
  final String merchantName;
  final String? userId;

  const ChatScreen({
    super.key,
    required this.merchantId,
    required this.merchantName,
    this.userId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatViewModel _viewModel;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<ChatViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_)=>
    _initializeChat());
  }

  Future<void> _initializeChat() async {
    dev.log('CHAT SERVICE INITIALIZED: ${widget.userId}');
    if (widget.userId != null && !_isInitialized) {
      await _viewModel.initialize(widget.userId!);
      _isInitialized = true;

      // Find existing conversation or create a new one
      final conversations = _viewModel.state.conversations;
      final existingConversation = conversations.firstWhere(
        (c) => c.merchantId == widget.merchantId,
        orElse:
            () => ChatConversation(
              id: '',
              userId: widget.userId!,
              merchantId: widget.merchantId,
              merchantName: widget.merchantName,
              lastMessageTime: DateTime.now(),
            ),
      );

      if (existingConversation.id.isNotEmpty) {
        await _viewModel.openConversation(existingConversation.id);
      } else {
        await _viewModel.createAndOpenConversation(
          widget.merchantId,
          widget.merchantName,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, viewModel, _) {
        final state = viewModel.state;

        return WillPopScope(
          onWillPop: () async {
            if (state.isAttachmentMenuOpen) {
              viewModel.toggleAttachmentMenu();
              return false;
            }
            if (state.isSelectionMode) {
              viewModel.toggleSelectionMode();
              return false;
            }
            if (state.isSearching) {
              viewModel.toggleSearchMode();
              return false;
            }
            return true;
          },
          child: Scaffold(
            appBar: ChatAppBar(
              conversation: state.activeConversation,
              isSelectionMode: state.isSelectionMode,
              selectedCount: state.selectedMessageIds.length,
              onBackPressed: () => Navigator.pop(context),
              onInfoPressed: () => _showMerchantInfo(viewModel),
              onClearSelection: viewModel.toggleSelectionMode,
              onDeleteSelected: viewModel.deleteSelectedMessages,
              isSearching: state.isSearching,
              onSearchPressed: viewModel.toggleSearchMode,
              onSearchChanged: viewModel.searchMessages,
            ),
            body: Column(
              children: [
                // Connection status bar
                if (!state.isConnected)
                  ConnectionStatusBar(onReconnect: viewModel.reconnect),

                // Main chat area
                Expanded(child: _buildChatContent(state, viewModel)),

                // Input area (only show if we have an active conversation)
                if (state.activeConversation != null)
                  ChatInput(
                    controller: state.messageController,
                    isRecording: state.isRecording,
                    isAttachmentMenuOpen: state.isAttachmentMenuOpen,
                    onTextChanged: viewModel.onTextChanged,
                    onSendPressed: viewModel.sendTextMessage,
                    onAttachmentPressed: viewModel.toggleAttachmentMenu,
                    onCameraPressed:
                        () => viewModel.sendImageMessage(ImageSource.camera),
                    onGalleryPressed:
                        () => viewModel.sendImageMessage(ImageSource.gallery),
                    onRecordStart: viewModel.startRecording,
                    onRecordStop: viewModel.stopRecordingAndSend,
                    onRecordCancel: viewModel.cancelRecording,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatContent(ChatState state, ChatViewModel viewModel) {
    // Show loading indicator while initializing
    if (state.viewState == ChatViewState.loading && !state.hasMessages) {
      return const LoadingIndicator();
    }

    // Show empty state if no active conversation or no messages
    if (!state.hasActiveConversation) {
      return EmptyChatView(
        message: 'Start a conversation with ${widget.merchantName}',
      );
    }

    // Show messages list
    return ChatMessagesList(
      messages: state.isSearching ? state.searchResults : state.messages,
      scrollController: state.scrollController,
      currentUserId: widget.userId ?? '',
      isSelectionMode: state.isSelectionMode,
      selectedMessageIds: state.selectedMessageIds.toSet(),
      onMessageTap:
          state.isSelectionMode ? viewModel.toggleMessageSelection : null,
      onMessageLongPress: (messageId) {
        if (!state.isSelectionMode) {
          viewModel.toggleSelectionMode();
          viewModel.toggleMessageSelection(messageId);
        }
      },
      onLoadMore: viewModel.loadMoreMessages,
      isLoadingMore: state.isLoadingMore,
      hasMoreMessages: state.hasMoreMessages,
    );
  }

  void _showMerchantInfo(ChatViewModel viewModel) {
    if (viewModel.state.activeConversation == null) return;

    final conversation = viewModel.state.activeConversation!;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.1),
                  child:
                      conversation.merchantAvatar != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: Image.network(
                              conversation.merchantAvatar!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Icon(
                                    Icons.business,
                                    size: 40,
                                    color: Theme.of(context).primaryColor,
                                  ),
                            ),
                          )
                          : Icon(
                            Icons.business,
                            size: 40,
                            color: Theme.of(context).primaryColor,
                          ),
                ),
                const SizedBox(height: 16),
                Text(
                  conversation.merchantName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Merchant ID: ${conversation.merchantId}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
    );
  }
}
