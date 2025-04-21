import 'package:flutter/material.dart';
import '../models/chat_conversation.dart';
import '../models/chat_message.dart';

enum ChatViewState {
  initial,
  loading,
  loaded,
  sending,
  error,
  offline,
  typing
}

class ChatState {
  final ChatViewState viewState;
  final List<ChatConversation> conversations;
  final ChatConversation? activeConversation;
  final List<ChatMessage> messages;
  final bool isConnected;
  final String? errorMessage;
  final bool isTyping;
  final String? typingUserId;
  final TextEditingController messageController;
  final ScrollController scrollController;
  final bool isAttachmentMenuOpen;
  final bool isRecording;
  final bool isSearching;
  final String searchQuery;
  final List<ChatMessage> searchResults;
  final bool isSelectionMode;
  final List<String> selectedMessageIds;
  final bool isLoadingMore;
  final bool hasMoreMessages;

  ChatState({
    this.viewState = ChatViewState.initial,
    this.conversations = const [],
    this.activeConversation,
    this.messages = const [],
    this.isConnected = true,
    this.errorMessage,
    this.isTyping = false,
    this.typingUserId,
    TextEditingController? messageController,
    ScrollController? scrollController,
    this.isAttachmentMenuOpen = false,
    this.isRecording = false,
    this.isSearching = false,
    this.searchQuery = '',
    this.searchResults = const [],
    this.isSelectionMode = false,
    this.selectedMessageIds = const [],
    this.isLoadingMore = false,
    this.hasMoreMessages = true,
  })  : messageController = messageController ?? TextEditingController(),
        scrollController = scrollController ?? ScrollController();

  bool get isLoading => viewState == ChatViewState.loading;
  bool get isSending => viewState == ChatViewState.sending;
  bool get hasError => viewState == ChatViewState.error;
  bool get isOffline => viewState == ChatViewState.offline;
  bool get hasActiveConversation => activeConversation != null;
  bool get hasMessages => messages.isNotEmpty;
  bool get hasSelectedMessages => selectedMessageIds.isNotEmpty;

  ChatState copyWith({
    ChatViewState? viewState,
    List<ChatConversation>? conversations,
    ChatConversation? activeConversation,
    List<ChatMessage>? messages,
    bool? isConnected,
    String? errorMessage,
    bool? isTyping,
    String? typingUserId,
    TextEditingController? messageController,
    ScrollController? scrollController,
    bool? isAttachmentMenuOpen,
    bool? isRecording,
    bool? isSearching,
    String? searchQuery,
    List<ChatMessage>? searchResults,
    bool? isSelectionMode,
    List<String>? selectedMessageIds,
    bool? isLoadingMore,
    bool? hasMoreMessages,
  }) {
    return ChatState(
      viewState: viewState ?? this.viewState,
      conversations: conversations ?? this.conversations,
      activeConversation: activeConversation ?? this.activeConversation,
      messages: messages ?? this.messages,
      isConnected: isConnected ?? this.isConnected,
      errorMessage: errorMessage ?? this.errorMessage,
      isTyping: isTyping ?? this.isTyping,
      typingUserId: typingUserId ?? this.typingUserId,
      messageController: messageController ?? this.messageController,
      scrollController: scrollController ?? this.scrollController,
      isAttachmentMenuOpen: isAttachmentMenuOpen ?? this.isAttachmentMenuOpen,
      isRecording: isRecording ?? this.isRecording,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedMessageIds: selectedMessageIds ?? this.selectedMessageIds,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
    );
  }

  ChatState clearError() {
    return copyWith(
      errorMessage: null,
      viewState: hasMessages ? ChatViewState.loaded : ChatViewState.initial,
    );
  }

  ChatState toggleSelectionMode() {
    return copyWith(
      isSelectionMode: !isSelectionMode,
      selectedMessageIds: [],
    );
  }

  ChatState toggleMessageSelection(String messageId) {
    final List<String> updatedSelection = List.from(selectedMessageIds);
    if (updatedSelection.contains(messageId)) {
      updatedSelection.remove(messageId);
    } else {
      updatedSelection.add(messageId);
    }
    
    return copyWith(
      selectedMessageIds: updatedSelection,
      isSelectionMode: updatedSelection.isNotEmpty,
    );
  }

  ChatState clearSelection() {
    return copyWith(
      isSelectionMode: false,
      selectedMessageIds: [],
    );
  }

  ChatState toggleAttachmentMenu() {
    return copyWith(
      isAttachmentMenuOpen: !isAttachmentMenuOpen,
    );
  }

  ChatState toggleSearchMode() {
    return copyWith(
      isSearching: !isSearching,
      searchQuery: '',
      searchResults: [],
    );
  }

  void dispose() {
    messageController.dispose();
    scrollController.dispose();
  }
}
