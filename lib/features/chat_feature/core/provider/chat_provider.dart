import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:my_ad/core/data/api/api_config.dart';
import 'package:pack/extensions/extensions.dart';
import '../services/api_client.dart';
import '../services/socket_services.dart';
import '../../models/models.dart';

enum ChatStatus { idle, loading, error, loaded }

class ChatProvider with ChangeNotifier {
  final ApiClient apiClient;
  final SocketService socketService;

  List<Conversation> conversations = [];
  List<Message> messages = [];
  Conversation? currentConversation;
  ChatStatus status = ChatStatus.idle;
  String? error;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isFetchingMore = false;

  // Stream subscription for real-time messages
  Stream<Message>? _messageStream;
  StreamSubscription<Message>? _messageSubscription;

  ChatProvider({required this.apiClient, required this.socketService});

  // Fetch all conversations for the user
  Future<void> fetchConversations(String userType, int userId) async {
    status = ChatStatus.loading;
    notifyListeners();
    try {
      conversations = await apiClient.getConversations(userType, userId);
      error = null;
      status = ChatStatus.loaded;
    } catch (e) {
      error = e.toString();
      status = ChatStatus.error;
    }
    notifyListeners();
  }

  // Select a conversation and fetch its messages (first page)
  Future<void> selectConversation(
    Conversation conversation, {
    int page = 1,
    int limit = 50,
  }) async {
    currentConversation = conversation;
    status = ChatStatus.loading;
    _currentPage = 1;
    _hasMore = true;
    messages.clear();
    notifyListeners();
    try {
      final fetched = await apiClient.getMessages(
        conversation.id,
        page: page,
        limit: limit,
      );
      messages = fetched;
      error = null;
      status = ChatStatus.loaded;
      listenForNewMessages();
    } catch (e) {
      error = e.toString();
      status = ChatStatus.error;
    }
    notifyListeners();
  }

  // Load more messages (pagination)
  Future<void> loadMoreMessages({int limit = 50}) async {
    if (!_hasMore || _isFetchingMore || currentConversation == null) return;
    _isFetchingMore = true;
    notifyListeners();
    try {
      final nextPage = _currentPage + 1;
      final fetched = await apiClient.getMessages(
        currentConversation!.id,
        page: nextPage,
        limit: limit,
      );
      if (fetched.isEmpty) {
        _hasMore = false;
      } else {
        messages.insertAll(0, fetched);
        _currentPage = nextPage;
      }
      error = null;
    } catch (e) {
      error = e.toString();
    }
    _isFetchingMore = false;
    notifyListeners();
  }

  // Send a message via API and emit via socket (optimistic UI)
  Future<void> sendMessage(Map<String, dynamic> data) async {
    dev.log('Sending message: $data');
    final optimisticMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch,
      conversationId: currentConversation?.id ?? 0,
      senderType: data['senderType'],
      senderId: int.tryParse(data['senderId'].toString()) ?? 0,
      message: data['message'],
      messageType: data['messageType'] ?? 'text',
      fileUrl: data['fileUrl'],
      isRead: false,
      readAt: null,
      createdAt: DateTime.now(),
      senderName: null,
      senderImage: null,
    );
    messages.add(optimisticMessage);
    notifyListeners();

    dev.log('Optimistic message: $optimisticMessage');
    try {
      final message = await apiClient.sendMessage(data);
      // Replace optimistic message with real one
      final idx = messages.indexWhere((m) => m.id == optimisticMessage.id);
      if (idx != -1) messages[idx] = message;
      socketService.sendMessage(data);
      error = null;
    } catch (e) {
      error = e.toString();
      // Remove optimistic message on error
      messages.removeWhere((m) => m.id == optimisticMessage.id);
    }
    notifyListeners();
  }

  void sendTyping(Map<String, dynamic> data) {
    socketService.sendTyping(data);
  }

  // Listen for new messages via socket (real-time)
  void listenForNewMessages() {
    _messageSubscription?.cancel();
    _messageStream = socketService.onNewMessage;
    _messageSubscription = _messageStream!.listen((msg) {
      if (currentConversation != null &&
          msg.conversationId == currentConversation!.id) {
        // Prevent duplicate messages
        if (!messages.any((m) => m.id == msg.id)) {
          messages.add(msg);
          notifyListeners();
        }
      }
    });
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String userType, int userId) async {
    if (currentConversation == null) return;
    try {
      await apiClient.markMessagesAsRead(
        currentConversation!.id,
        userType,
        userId,
      );
      for (var msg in messages) {
        msg.copyWith(isRead: true, readAt: DateTime.now());
      }
      error = null;
    } catch (e) {
      error = e.toString();
    }
    notifyListeners();
  }

  // Refresh current conversation messages
  Future<void> refreshMessages({int limit = 50}) async {
    if (currentConversation == null) return;
    status = ChatStatus.loading;
    notifyListeners();
    try {
      final fetched = await apiClient.getMessages(
        currentConversation!.id,
        page: 1,
        limit: limit,
      );
      messages = fetched;
      error = null;
      status = ChatStatus.loaded;
    } catch (e) {
      error = e.toString();
      status = ChatStatus.error;
    }
    notifyListeners();
  }

  // Handle socket disconnect
  void handleSocketDisconnect() {
    _messageSubscription?.cancel();
    _messageStream = null;
  }

  // Clear chat state
  void clear() {
    conversations.clear();
    messages.clear();
    currentConversation = null;
    error = null;
    status = ChatStatus.idle;
    _currentPage = 1;
    _hasMore = true;
    _isFetchingMore = false;
    handleSocketDisconnect();
    notifyListeners();
  }

  @override
  void dispose() {
    handleSocketDisconnect();
    super.dispose();
  }
}
