import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chat_conversation.dart';
import '../models/chat_message.dart';
import '../services/i_chat_service.dart';

class ChatRepositories {
  final IChatService _chatService;

  // In-memory cache
  final Map<String, List<ChatMessage>> _messagesCache = {};
  final Map<String, ChatConversation> _conversationsCache = {};
  List<ChatConversation> _allConversations = [];

  // Stream controllers
  final StreamController<List<ChatMessage>> _messagesStreamController =
      StreamController<List<ChatMessage>>.broadcast();
  final StreamController<List<ChatConversation>>
  _conversationsStreamController =
      StreamController<List<ChatConversation>>.broadcast();
  final StreamController<String> _typingStreamController =
      StreamController<String>.broadcast();

  // Streams
  Stream<List<ChatMessage>> get messagesStream =>
      _messagesStreamController.stream;
  Stream<List<ChatConversation>> get conversationsStream =>
      _conversationsStreamController.stream;
  Stream<String> get typingStream => _typingStreamController.stream;

  ChatRepositories(this._chatService) {
    // Listen to service events
    _chatService.onMessageReceived().listen(_handleNewMessage);
    // _chatService.onConversationUpdated().listen(_handleConversationUpdate);
    _chatService.onTypingIndicator().listen(_handleTypingStatus);
    _chatService.onConnectionStatusChanged().listen(_handleConnectionStatus);
  }

  // Initialize the repository
  Future<void> initialize(String userId) async {
    await _chatService.connect(userId);
    await refreshConversations();
  }

  // Get all conversations for a user
  Future<List<ChatConversation>> getConversations(String userId) async {
    try {
      final conversations = await _chatService.getConversations(userId);
      _allConversations = conversations;

      // Update cache
      for (final conversation in conversations) {
        _conversationsCache[conversation.id] = conversation;
      }

      // Notify listeners
      _conversationsStreamController.add(_allConversations);

      return conversations;
    } catch (e) {
      debugPrint('Error fetching conversations: $e');
      rethrow;
    }
  }

  // Refresh conversations
  Future<void> refreshConversations() async {
    try {
      final userId = _chatService.currentUserId;
      if (userId != null) {
        await getConversations(userId);
      }
    } catch (e) {
      debugPrint('Error refreshing conversations: $e');
    }
  }

  // Get a specific conversation
  Future<ChatConversation?> getConversation(String conversationId) async {
    try {
      // Check cache first
      if (_conversationsCache.containsKey(conversationId)) {
        return _conversationsCache[conversationId];
      }

      // Fetch from service
      final conversation = await _chatService.getConversation(conversationId);
      _conversationsCache[conversationId] = conversation;

      return conversation;
    } catch (e) {
      debugPrint('Error fetching conversation: $e');
      rethrow;
    }
  }

  // Create a new conversation
  Future<ChatConversation> createConversation(
    String userId,
    String merchantId,
    String merchantName,
  ) async {
    try {
      final conversation = await _chatService.createConversation(
        userId,
        merchantId,
        merchantName,
      );

      // Update cache
      _conversationsCache[conversation.id] = conversation;
      _allConversations = [conversation, ..._allConversations];

      // Notify listeners
      _conversationsStreamController.add(_allConversations);

      return conversation;
    } catch (e) {
      debugPrint('Error creating conversation: $e');
      rethrow;
    }
  }

  // Get messages for a conversation
  Future<List<ChatMessage>> getMessages(
    String conversationId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Fetch from service
      final messages = await _chatService.getMessages(
        conversationId,
        limit: limit,
        offset: offset,
      );

      // Update cache
      if (offset == 0) {
        // Replace cache if it's the first page
        _messagesCache[conversationId] = messages;
      } else {
        // Append to cache for pagination
        final existingMessages = _messagesCache[conversationId] ?? [];
        _messagesCache[conversationId] = [...existingMessages, ...messages];
      }

      // Sort messages by timestamp (newest first)
      _messagesCache[conversationId]?.sort(
        (a, b) => b.timestamp.compareTo(a.timestamp),
      );

      // Notify listeners
      _messagesStreamController.add(_messagesCache[conversationId] ?? []);

      return messages;
    } catch (e) {
      debugPrint('Error fetching messages: $e');
      rethrow;
    }
  }

  // Send a message
  Future<ChatMessage> sendMessage(
    String conversationId,
    String content,
    MessageType type, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final message = await _chatService.sendMessage(
        conversationId,
        content,
        type,
        metadata: metadata,
      );

      // Update messages cache
      final messages = _messagesCache[conversationId] ?? [];
      _messagesCache[conversationId] = [message, ...messages];

      // Notify listeners
      _messagesStreamController.add(_messagesCache[conversationId] ?? []);

      // Update conversation with last message
      final conversation = _conversationsCache[conversationId];
      if (conversation != null) {
        final updatedConversation = conversation.copyWith(
          lastMessage: content,
          lastMessageTime: message.timestamp,
        );

        _conversationsCache[conversationId] = updatedConversation;

        // Update all conversations list
        _allConversations =
            _allConversations.map((c) {
              return c.id == conversationId ? updatedConversation : c;
            }).toList();

        // Sort conversations by last message time (newest first)
        _allConversations.sort(
          (a, b) => b.lastMessageTime.compareTo(a.lastMessageTime),
        );

        // Notify listeners
        _conversationsStreamController.add(_allConversations);
      }

      return message;
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  // Delete a message
  Future<void> deleteMessages(String conversationId, List<String> messageIds) async {
    try {
      await _chatService.deleteMessages(conversationId, messageIds);

      // Update all message caches
      for (final conversationId in _messagesCache.keys) {
        final messages = _messagesCache[conversationId] ?? [];
        final messageIndex = messages.indexWhere((m) => m.id == messageIds);

        if (messageIndex >= 0) {
          // Mark message as deleted
          final deletedMessage = messages[messageIndex].copyWith(
            isDeleted: true,
          );
          messages[messageIndex] = deletedMessage;
          _messagesCache[conversationId] = messages;

          // Notify listeners
          _messagesStreamController.add(messages);

          // Update conversation if it was the last message
          final conversation = _conversationsCache[conversationId];
          if (conversation != null) {
            final lastMessage = messages.firstWhere(
              (m) => !m.isDeleted,
              orElse: () => messages.first,
            );

            final updatedConversation = conversation.copyWith(
              lastMessage:
                  lastMessage.isDeleted
                      ? 'This message was deleted'
                      : lastMessage.content,
              lastMessageTime: lastMessage.timestamp,
            );

            _conversationsCache[conversationId] = updatedConversation;

            // Update all conversations list
            _allConversations =
                _allConversations.map((c) {
                  return c.id == conversationId ? updatedConversation : c;
                }).toList();

            // Notify listeners
            _conversationsStreamController.add(_allConversations);
          }

          break;
        }
      }
    } catch (e) {
      debugPrint('Error deleting message: $e');
      rethrow;
    }
  }

  // Mark conversation as read
// Mark conversation as read
  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      final messages = _messagesCache[conversationId] ?? [];
      final unreadMessageIds = messages
          .where((m) => m.status != MessageStatus.read)
          .map((m) => m.id)
          .toList();

      if (unreadMessageIds.isNotEmpty) {
        await _chatService.markMessagesAsRead(conversationId, unreadMessageIds);

        // Update conversation in cache
        final conversation = _conversationsCache[conversationId];
        if (conversation != null) {
          final updatedConversation = conversation.copyWith(unreadCount: 0);
          _conversationsCache[conversationId] = updatedConversation;

          // Update all conversations list
          _allConversations = _allConversations.map((c) {
            return c.id == conversationId ? updatedConversation : c;
          }).toList();

          // Notify listeners
          _conversationsStreamController.add(_allConversations);
        }
      }
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
      rethrow;
    }
  }
  // Send typing indicator
  void sendTypingIndicator(String conversationId, bool isTyping) {
    _chatService.sendTypingIndicator(conversationId, isTyping);
  }

  // Reconnect to the chat service
  Future<void> reconnect() async {
    try {
      final userId = _chatService.currentUserId;
      if (userId != null) {
        await _chatService.connect(userId);
        await refreshConversations();
      }
    } catch (e) {
      debugPrint('Error reconnecting: $e');
      rethrow;
    }
  }

  // Disconnect from the chat service
  Future<void> disconnect() async {
    await _chatService.disconnect();
  }

  // Handle new message from service
  void _handleNewMessage(ChatMessage message) {
    // Update messages cache
    final conversationId = message.metadata?['conversationId'] as String?;
    if (conversationId != null) {
      final messages = _messagesCache[conversationId] ?? [];

      // Check if message already exists
      final exists = messages.any((m) => m.id == message.id);
      if (!exists) {
        _messagesCache[conversationId] = [message, ...messages];

        // Notify listeners
        _messagesStreamController.add(_messagesCache[conversationId] ?? []);
      }
    }
  }

  // Handle conversation update from service
  void _handleConversationUpdate(ChatConversation conversation) {
    // Update conversation in cache
    _conversationsCache[conversation.id] = conversation;

    // Update all conversations list
    final index = _allConversations.indexWhere((c) => c.id == conversation.id);
    if (index >= 0) {
      _allConversations[index] = conversation;
    } else {
      _allConversations = [conversation, ..._allConversations];
    }

    // Sort conversations by last message time (newest first)
    _allConversations.sort(
      (a, b) => b.lastMessageTime.compareTo(a.lastMessageTime),
    );

    // Notify listeners
    _conversationsStreamController.add(_allConversations);
  }

  // Handle typing status from service
  void _handleTypingStatus(Map<String, dynamic> data) {
    final userId = data['userId'] as String?;
    final conversationId = data['conversationId'] as String?;
    final isTyping = data['isTyping'] as bool?;

    if (userId != null &&
        conversationId != null &&
        isTyping != null &&
        isTyping) {
      _typingStreamController.add(userId);
    }
  }

  // Handle connection status from service
  void _handleConnectionStatus(bool isConnected) {
    // This could be used to update UI or trigger reconnection attempts
    debugPrint('Connection status changed: $isConnected');
  }

  // Dispose resources
  void dispose() {
    _messagesStreamController.close();
    _conversationsStreamController.close();
    _typingStreamController.close();
    _chatService.disconnect();
  }
}
