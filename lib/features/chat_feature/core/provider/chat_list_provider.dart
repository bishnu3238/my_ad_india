import 'package:flutter/material.dart';
 import '../../models/models.dart';
import '../../screens/chat/core/chat_list_state.dart';
import '../services/chat_list_service.dart';

class ChatListProvider with ChangeNotifier {
  final ChatListService chatListService;

  ChatListState _state = ChatListState.initial();
  ChatListState get state => _state;

  // UI callbacks
  VoidCallback? onConversationsLoaded;
  VoidCallback? onError;
  VoidCallback? onRefresh;
  VoidCallback? onBatchAction;

  ChatListProvider({required this.chatListService});

  Future<void> loadConversations({
    required String userType,
    required int userId,
  }) async {
    _state = _state.copyWith(status: ChatListStatus.loading, error: null);
    notifyListeners();
    try {
      final conversations = await chatListService.fetchConversations(
        userType: userType,
        userId: userId,
      );
      final unreadCount = conversations.fold<int>(
        0,
            (sum, c) => sum + (c.unreadCount ?? 0),
      );
      _state = _state.copyWith(
        conversations: conversations,
        status: conversations.isEmpty ? ChatListStatus.empty : ChatListStatus.loaded,
        error: null,
        unreadCount: unreadCount,
        lastSync: DateTime.now(),
      );
      onConversationsLoaded?.call();
    } catch (e) {
      _state = _state.copyWith(
        status: ChatListStatus.error,
        error: _friendlyError(e),
      );
      onError?.call();
    }
    notifyListeners();
  }

  Future<void> refresh({
    required String userType,
    required int userId,
  }) async {
    _state = _state.copyWith(status: ChatListStatus.refreshing);
    notifyListeners();
    await loadConversations(userType: userType, userId: userId);
    onRefresh?.call();
  }

  void clear() {
    _state = ChatListState.initial();
    notifyListeners();
  }

  Conversation? getConversationById(int id) {
    return _state.conversations.firstWhere((c) => c.id == id, orElse: () => Conversation.empty);
  }

  Future<void> deleteConversation(int conversationId) async {
    try {
      await chatListService.deleteConversation(conversationId);
      _state = _state.copyWith(
        conversations: _state.conversations.where((c) => c.id != conversationId).toList(),
        unreadCount: _recalculateUnread(),
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(error: _friendlyError(e));
      notifyListeners();
    }
  }

  Future<void> archiveConversation(int conversationId) async {
    try {
      await chatListService.archiveConversation(conversationId);
      _state = _state.copyWith(
        conversations: _state.conversations.where((c) => c.id != conversationId).toList(),
        unreadCount: _recalculateUnread(),
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(error: _friendlyError(e));
      notifyListeners();
    }
  }

  // Selection logic for batch actions
  void toggleSelect(int conversationId) {
    final selected = Set<int>.from(_state.selectedIds);
    if (selected.contains(conversationId)) {
      selected.remove(conversationId);
    } else {
      selected.add(conversationId);
    }
    _state = _state.copyWith(selectedIds: selected);
    notifyListeners();
  }

  void clearSelection() {
    _state = _state.copyWith(selectedIds: {});
    notifyListeners();
  }

  Future<void> batchDeleteSelected() async {
    final ids = _state.selectedIds.toList();
    try {
      await chatListService.batchDelete(ids);
      _state = _state.copyWith(
        conversations: _state.conversations.where((c) => !ids.contains(c.id)).toList(),
        selectedIds: {},
        unreadCount: _recalculateUnread(),
      );
      onBatchAction?.call();
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(error: _friendlyError(e));
      notifyListeners();
    }
  }

  Future<void> batchArchiveSelected() async {
    final ids = _state.selectedIds.toList();
    try {
      await chatListService.batchArchive(ids);
      _state = _state.copyWith(
        conversations: _state.conversations.where((c) => !ids.contains(c.id)).toList(),
        selectedIds: {},
        unreadCount: _recalculateUnread(),
      );
      onBatchAction?.call();
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(error: _friendlyError(e));
      notifyListeners();
    }
  }

  void markAllAsRead() {
    final updated = _state.conversations
        .map((c) => c.copyWith(unreadCount: 0))
        .toList();
    _state = _state.copyWith(conversations: updated, unreadCount: 0);
    notifyListeners();
  }

  int _recalculateUnread() {
    return _state.conversations.fold<int>(
      0,
          (sum, c) => sum + (c.unreadCount ?? 0),
    );
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('SocketException')) return 'Network error. Please check your connection.';
    if (msg.contains('404')) return 'Resource not found.';
    if (msg.contains('401')) return 'Unauthorized. Please login again.';
    return msg;
  }
}
