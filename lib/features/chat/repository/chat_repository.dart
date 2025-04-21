import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chat_conversation.dart';
import '../models/chat_message.dart';
import '../services/i_chat_service.dart';

class ChatRepository {
  final IChatService _chatService;
  
  // Cache for conversations and messages
  final Map<String, ChatConversation> _conversationsCache = {};
  final Map<String, List<ChatMessage>> _messagesCache = {};
  
  // Stream controllers for reactive updates
  final _conversationsController = StreamController<List<ChatConversation>>.broadcast();
  final _activeConversationController = StreamController<ChatConversation?>.broadcast();
  final _messagesController = StreamController<List<ChatMessage>>.broadcast();
  
  // Active conversation ID
  String? _activeConversationId;
  
  // Subscription management
  final List<StreamSubscription> _subscriptions = [];
  
  ChatRepository(this._chatService) {
    _setupListeners();
  }
  
  // Getters for streams
  Stream<List<ChatConversation>> get conversationsStream => _conversationsController.stream;
  Stream<ChatConversation?> get activeConversationStream => _activeConversationController.stream;
  Stream<List<ChatMessage>> get messagesStream => _messagesController.stream;
  
  // Initialize repository with user ID
  Future<void> initialize(String userId) async {
    await _chatService.initialize(userId);
    await refreshConversations();
  }
  
  // Set up listeners for real-time updates
  void _setupListeners() {
    // Listen for new messages
    _subscriptions.add(_chatService.onMessageReceived().listen((message) {
      _handleNewMessage(message);
    }));
    
    // Listen for message status updates
    _subscriptions.add(_chatService.onMessageStatusChanged().listen((message) {
      _updateMessageStatus(message);
    }));
    
    // Listen for connection status changes
    _subscriptions.add(_chatService.onConnectionStatusChanged().listen((isConnected) {
      if (isConnected && _activeConversationId != null) {
        // Refresh data when reconnected
        refreshMessages(_activeConversationId!);
      }
    }));
  }
  
  // Handle incoming message
  void _handleNewMessage(ChatMessage message) {
    // Find the conversation this message belongs to
    final conversationId = _findConversationIdForMessage(message);
    if (conversationId != null) {
      // Update messages cache
      if (_messagesCache.containsKey(conversationId)) {
        final updatedMessages = List<ChatMessage>.from(_messagesCache[conversationId]!);
        
        // Check if message already exists (avoid duplicates)
        final existingIndex = updatedMessages.indexWhere((m) => m.id == message.id);
        if (existingIndex >= 0) {
          updatedMessages[existingIndex] = message;
        } else {
          updatedMessages.add(message);
        }
        
        // Sort messages by timestamp
        updatedMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        
        // Update cache
        _messagesCache[conversationId] = updatedMessages;
        
        // Emit updated messages if this is the active conversation
        if (conversationId == _activeConversationId) {
          _messagesController.add(updatedMessages);
        }
      }
      
      // Update conversation with latest message
      if (_conversationsCache.containsKey(conversationId)) {
        final conversation = _conversationsCache[conversationId]!;
        final updatedConversation = conversation.copyWith(
          lastMessage: message.content,
          lastMessageTime: message.timestamp,
          unreadCount: conversation.unreadCount + 1,
        );
        
        // Update cache
        _conversationsCache[conversationId] = updatedConversation;
        
        // Emit updated conversations
        _conversationsController.add(_conversationsCache.values.toList());
        
        // Update active conversation if needed
        if (conversationId == _activeConversationId) {
          _activeConversationController.add(updatedConversation);
        }
      }
    }
  }
  
  // Find conversation ID for a message
  String? _findConversationIdForMessage(ChatMessage message) {
    // First check if message belongs to active conversation
    if (_activeConversationId != null && 
        _conversationsCache.containsKey(_activeConversationId)) {
      final conversation = _conversationsCache[_activeConversationId]!;
      if (conversation.merchantId == message.senderId || 
          conversation.merchantId == message.receiverId) {
        return _activeConversationId;
      }
    }
    
    // Otherwise search all conversations
    for (final entry in _conversationsCache.entries) {
      final conversation = entry.value;
      if (conversation.merchantId == message.senderId || 
          conversation.merchantId == message.receiverId) {
        return entry.key;
      }
    }
    
    return null;
  }
  
  // Update message status
  void _updateMessageStatus(ChatMessage updatedMessage) {
    // Find the conversation this message belongs to
    final conversationId = _findConversationIdForMessage(updatedMessage);
    if (conversationId != null && _messagesCache.containsKey(conversationId)) {
      final messages = _messagesCache[conversationId]!;
      final index = messages.indexWhere((m) => m.id == updatedMessage.id);
      
      if (index >= 0) {
        // Update message
        final updatedMessages = List<ChatMessage>.from(messages);
        updatedMessages[index] = updatedMessage;
        
        // Update cache
        _messagesCache[conversationId] = updatedMessages;
        
        // Emit updated messages if this is the active conversation
        if (conversationId == _activeConversationId) {
          _messagesController.add(updatedMessages);
        }
      }
    }
  }
  
  // Fetch all conversations
  Future<List<ChatConversation>> refreshConversations() async {
    try {
      final conversations = await _chatService.getConversations(_chatService.currentUserId!);
      
      // Update cache
      for (final conversation in conversations) {
        _conversationsCache[conversation.id] = conversation;
      }
      
      // Sort conversations by last message time
      final sortedConversations = conversations
          .toList()
          ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      
      // Emit updated conversations
      _conversationsController.add(sortedConversations);
      
      return sortedConversations;
    } catch (e) {
      debugPrint('Error refreshing conversations: $e');
      // Return cached conversations if available
      if (_conversationsCache.isNotEmpty) {
        final cachedConversations = _conversationsCache.values.toList()
          ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
        return cachedConversations;
      }
      rethrow;
    }
  }
  
  // Get a specific conversation
  Future<ChatConversation> getConversation(String conversationId) async {
    try {
      // Check cache first
      if (_conversationsCache.containsKey(conversationId)) {
        return _conversationsCache[conversationId]!;
      }
      
      // Fetch from service
      final conversation = await _chatService.getConversation(conversationId);
      
      // Update cache
      _conversationsCache[conversationId] = conversation;
      
      return conversation;
    } catch (e) {
      debugPrint('Error getting conversation: $e');
      rethrow;
    }
  }
  
  // Create a new conversation
  Future<ChatConversation> createConversation(String merchantId, String merchantName) async {
    try {
      final conversation = await _chatService.createConversation(_chatService.currentUserId!, merchantId, merchantName);
      
      // Update cache
      _conversationsCache[conversation.id] = conversation;
      
      // Emit updated conversations
      _conversationsController.add(_conversationsCache.values.toList());
      
      return conversation;
    } catch (e) {
      debugPrint('Error creating conversation: $e');
      rethrow;
    }
  }
  
  // Set active conversation
  Future<void> setActiveConversation(String conversationId) async {
    _activeConversationId = conversationId;
    
    // Get conversation details
    final conversation = await getConversation(conversationId);
    
    // Emit active conversation
    _activeConversationController.add(conversation);
    
    // Fetch messages for this conversation
    await refreshMessages(conversationId);
    
    // Mark unread messages as read
    if (conversation.unreadCount > 0) {
      await markConversationAsRead(conversationId);
    }
  }
  
  // Clear active conversation
  void clearActiveConversation() {
    _activeConversationId = null;
    _activeConversationController.add(null);
    _messagesController.add([]);
  }
  
  // Fetch messages for a conversation
  Future<List<ChatMessage>> refreshMessages(String conversationId, {int limit = 50, int offset = 0}) async {
    try {
      final messages = await _chatService.getMessages(conversationId, limit: limit, offset: offset);
      
      // Update cache
      if (offset == 0) {
        // Replace cache if fetching from the beginning
        _messagesCache[conversationId] = messages;
      } else {
        // Prepend older messages if paginating
        final existingMessages = _messagesCache[conversationId] ?? [];
        final combinedMessages = [...messages, ...existingMessages];
        
        // Remove duplicates
        final uniqueMessages = <String, ChatMessage>{};
        for (final message in combinedMessages) {
          uniqueMessages[message.id] = message;
        }
        
        _messagesCache[conversationId] = uniqueMessages.values.toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      }
      
      // Emit updated messages if this is the active conversation
      if (conversationId == _activeConversationId) {
        _messagesController.add(_messagesCache[conversationId]!);
      }
      
      return _messagesCache[conversationId]!;
    } catch (e) {
      debugPrint('Error refreshing messages: $e');
      // Return cached messages if available
      if (_messagesCache.containsKey(conversationId)) {
        return _messagesCache[conversationId]!;
      }
      rethrow;
    }
  }
  
  // Send a message
  Future<ChatMessage> sendMessage(String conversationId, String content, MessageType type) async {
    try {
      final message = await _chatService.sendMessage(conversationId, content, type);
      
      // Update messages cache
      if (_messagesCache.containsKey(conversationId)) {
        final updatedMessages = List<ChatMessage>.from(_messagesCache[conversationId]!);
        updatedMessages.add(message);
        _messagesCache[conversationId] = updatedMessages;
        
        // Emit updated messages if this is the active conversation
        if (conversationId == _activeConversationId) {
          _messagesController.add(updatedMessages);
        }
      }
      
      // Update conversation with latest message
      if (_conversationsCache.containsKey(conversationId)) {
        final conversation = _conversationsCache[conversationId]!;
        final updatedConversation = conversation.copyWith(
          lastMessage: message.content,
          lastMessageTime: message.timestamp,
        );
        
        // Update cache
        _conversationsCache[conversationId] = updatedConversation;
        
        // Emit updated conversations
        _conversationsController.add(_conversationsCache.values.toList());
        
        // Update active conversation if needed
        if (conversationId == _activeConversationId) {
          _activeConversationController.add(updatedConversation);
        }
      }
      
      return message;
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }
  
  // Send typing indicator
  Future<void> sendTypingIndicator(String conversationId, bool isTyping) async {
    await _chatService.sendTypingIndicator(conversationId, isTyping);
  }
  
  // Mark conversation as read
  Future<void> markConversationAsRead(String conversationId) async {
    try {
      // Get unread message IDs
      final messages = _messagesCache[conversationId] ?? [];
      final unreadMessageIds = messages
          .where((m) => m.status != MessageStatus.read)
          .map((m) => m.id)
          .toList();
      
      if (unreadMessageIds.isNotEmpty) {
        await _chatService.markMessagesAsRead(conversationId, unreadMessageIds);
        
        // Update conversation unread count
        if (_conversationsCache.containsKey(conversationId)) {
          final conversation = _conversationsCache[conversationId]!;
          final updatedConversation = conversation.copyWith(unreadCount: 0);
          
          // Update cache
          _conversationsCache[conversationId] = updatedConversation;
          
          // Emit updated conversations
          _conversationsController.add(_conversationsCache.values.toList());
          
          // Update active conversation if needed
          if (conversationId == _activeConversationId) {
            _activeConversationController.add(updatedConversation);
          }
        }
        
        // Update message status in cache
        if (_messagesCache.containsKey(conversationId)) {
          final updatedMessages = _messagesCache[conversationId]!.map((message) {
            if (unreadMessageIds.contains(message.id)) {
              return message.copyWith(status: MessageStatus.read);
            }
            return message;
          }).toList();
          
          // Update cache
          _messagesCache[conversationId] = updatedMessages;
          
          // Emit updated messages if this is the active conversation
          if (conversationId == _activeConversationId) {
            _messagesController.add(updatedMessages);
          }
        }
      }
    } catch (e) {
      debugPrint('Error marking conversation as read: $e');
      rethrow;
    }
  }
  
  // Delete messages
  Future<void> deleteMessages(String conversationId, List<String> messageIds) async {
    try {
      await _chatService.deleteMessages(conversationId, messageIds);
      
      // Update messages cache
      if (_messagesCache.containsKey(conversationId)) {
        final updatedMessages = _messagesCache[conversationId]!.map((message) {
          if (messageIds.contains(message.id)) {
            return message.copyWith(isDeleted: true);
          }
          return message;
        }).toList();
        
        // Update cache
        _messagesCache[conversationId] = updatedMessages;
        
        // Emit updated messages if this is the active conversation
        if (conversationId == _activeConversationId) {
          _messagesController.add(updatedMessages);
        }
      }
    } catch (e) {
      debugPrint('Error deleting messages: $e');
      rethrow;
    }
  }
  
  // Upload file
  Future<String> uploadFile(String conversationId, String filePath, MessageType type) async {
    try {
      return await _chatService.uploadFile(conversationId, filePath, type);
    } catch (e) {
      debugPrint('Error uploading file: $e');
      rethrow;
    }
  }
  
  // Check connection status
  bool isConnected() {
    return _chatService.isConnected();
  }
  
  // Connect to chat server
  Future<bool> connect() async {
    return await _chatService.connect(_chatService.currentUserId!);
  }
  
  // Disconnect from chat server
  Future<void> disconnect() async {
    await _chatService.disconnect();
  }
  
  // Dispose resources
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _conversationsController.close();
    _activeConversationController.close();
    _messagesController.close();
  }
}
