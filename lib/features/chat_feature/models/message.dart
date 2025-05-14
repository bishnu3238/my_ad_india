import 'package:equatable/equatable.dart';
import 'package:my_ad/features/chat_feature/models/models.dart';
import 'package:pack/extensions/extensions.dart';

enum MessageStatus { sending, sent, delivered, read, failed }

enum MessageType { text, image, audio, video, document, location }

class Message extends Equatable {
  final int id;
  final int conversationId;
  final String senderType;
  final int senderId;
  final String message;
  final String messageType;
  final String? fileUrl;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final String? senderName;
  final String? senderImage;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderType,
    required this.senderId,
    required this.message,
    required this.messageType,
    this.fileUrl,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    this.senderName,
    this.senderImage,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json.getInt('id'),
    conversationId: json.getInt('conversation_id'),
    senderType: json.getString('sender_type'),
    senderId: json.getInt('sender_id'),
    message: json.getString('message'),
    messageType: json.getString('message_type'),
    fileUrl: json.getString('file_url'),
    // isRead: json['is_read'] == true || json['is_read'] == 1,
    isRead: json.getBool('is_read'),
    readAt: json.getDateTime('read_at'),
    // != null ? DateTime.parse(json['read_at']) : null,
    createdAt: json.getDateTime('created_at'),
    senderName: json.getString('sender_name'),
    senderImage: json.getString('sender_image'),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'conversation_id': conversationId,
    'sender_type': senderType,
    'sender_id': senderId,
    'message': message,
    'message_type': messageType,
    'file_url': fileUrl,
    'is_read': isRead,
    'read_at': readAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'sender_name': senderName,
    'sender_image': senderImage,
  };

  @override
  String toString() {
    return 'Message{id: $id, conversationId: $conversationId, senderType: $senderType, senderId: $senderId, message: $message, messageType: $messageType, fileUrl: $fileUrl, isRead: $isRead, readAt: $readAt, createdAt: $createdAt, senderName: $senderName, senderImage: $senderImage}';
  }

  Message copyWith({
    int? id,
    int? conversationId,
    String? senderType,
    int? senderId,
    String? message,
    String? messageType,
    String? fileUrl,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    String? senderName,
    String? senderImage,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderType: senderType ?? this.senderType,
      senderId: senderId ?? this.senderId,
      message: message ?? this.message,
      messageType: messageType ?? this.messageType,
      fileUrl: fileUrl ?? this.fileUrl,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      senderName: senderName ?? this.senderName,
      senderImage: senderImage ?? this.senderImage,
    );
  }

  static Message empty = Message(
    id: 0,
    conversationId: 0,
    senderType: '',
    senderId: 0,
    message: '',
    messageType: '',
    fileUrl: null,
    isRead: false,
    readAt: null,
    createdAt: DateTime.now(),
    senderName: null,
    senderImage: null,
  );

  @override
  List<Object?> get props => [
    id,
    conversationId,
    senderType,
    senderId,
    message,
    messageType,
    fileUrl,
    isRead,
    readAt,
    createdAt,
    senderName,
    senderImage,
  ];
}
