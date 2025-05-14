import '../../../models/models.dart';

enum ChatListStatus { idle, loading, loaded, error, refreshing, empty }

class ChatListState {
  final List<Conversation> conversations;
  final ChatListStatus status;
  final String? error;
  final int unreadCount;
  final Set<int> selectedIds;
  final DateTime? lastSync;

  ChatListState({
    required this.conversations,
    required this.status,
    this.error,
    this.unreadCount = 0,
    Set<int>? selectedIds,
    this.lastSync,
  }) : selectedIds = selectedIds ?? {};

  ChatListState copyWith({
    List<Conversation>? conversations,
    ChatListStatus? status,
    String? error,
    int? unreadCount,
    Set<int>? selectedIds,
    DateTime? lastSync,
  }) {
    return ChatListState(
      conversations: conversations ?? this.conversations,
      status: status ?? this.status,
      error: error,
      unreadCount: unreadCount ?? this.unreadCount,
      selectedIds: selectedIds ?? this.selectedIds,
      lastSync: lastSync ?? this.lastSync,
    );
  }

  factory ChatListState.initial() => ChatListState(
    conversations: [],
    status: ChatListStatus.idle,
    error: null,
    unreadCount: 0,
    selectedIds: {},
    lastSync: null,
  );
}
