import 'package:equatable/equatable.dart';
import 'chat_message.dart';

class ChatConversation extends Equatable {
  final String id;
  final String userId;
  final String merchantId;
  final String merchantName;
  final String? merchantAvatar;
  final String? lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isActive;
  final List<ChatMessage> messages;

  const ChatConversation({
    required this.id,
    required this.userId,
    required this.merchantId,
    required this.merchantName,
    this.merchantAvatar,
    this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isActive = true,
    this.messages = const [],
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'],
      userId: json['userId'],
      merchantId: json['merchantId'],
      merchantName: json['merchantName'],
      merchantAvatar: json['merchantAvatar'],
      lastMessage: json['lastMessage'],
      lastMessageTime: DateTime.parse(json['lastMessageTime']),
      unreadCount: json['unreadCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      messages: json['messages'] != null
          ? List<ChatMessage>.from(
              json['messages'].map((x) => ChatMessage.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'merchantId': merchantId,
      'merchantName': merchantName,
      'merchantAvatar': merchantAvatar,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unreadCount': unreadCount,
      'isActive': isActive,
      'messages': messages.map((x) => x.toJson()).toList(),
    };
  }

  ChatConversation copyWith({
    String? id,
    String? userId,
    String? merchantId,
    String? merchantName,
    String? merchantAvatar,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isActive,
    List<ChatMessage>? messages,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      merchantId: merchantId ?? this.merchantId,
      merchantName: merchantName ?? this.merchantName,
      merchantAvatar: merchantAvatar ?? this.merchantAvatar,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isActive: isActive ?? this.isActive,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        merchantId,
        merchantName,
        merchantAvatar,
        lastMessage,
        lastMessageTime,
        unreadCount,
        isActive,
        messages,
      ];
}
