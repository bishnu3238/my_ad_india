import 'dart:convert';

class Conversation {
  final String id;
  final String customerId;
  final String merchantId;
  final String lastMessage;
  final DateTime lastMessageTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String otherUserName;
  final String otherUserImage;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.customerId,
    required this.merchantId,
    this.lastMessage = '',
    required this.lastMessageTime,
    required this.createdAt,
    required this.updatedAt,
    required this.otherUserName,
    required this.otherUserImage,
    this.unreadCount = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'].toString(),
      customerId: json['customer_id'].toString(),
      merchantId: json['merchant_id'].toString(),
      lastMessage: json['last_message'] ?? '',
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : DateTime.now(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      otherUserName: json['customer_name'] ?? json['merchant_name'] ?? 'Unknown',
      otherUserImage: json['customer_image'] ?? json['merchant_image'] ?? '',
      unreadCount: json['unread_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'merchant_id': merchantId,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'other_user_name': otherUserName,
      'other_user_image': otherUserImage,
      'unread_count': unreadCount,
    };
  }
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderType;
  final String senderId;
  final String message;
  final String messageType;
  final String? fileUrl;
  final bool isRead;
  final DateTime createdAt;
  final String senderName;
  final String senderImage;
  final bool isMine;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderType,
    required this.senderId,
    required this.message,
    required this.messageType,
    this.fileUrl,
    required this.isRead,
    required this.createdAt,
    required this.senderName,
    required this.senderImage,
    required this.isMine,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String currentUserId) {
    final senderType = json['sender_type'] ?? '';
    final senderId = json['sender_id'].toString();
    
    return ChatMessage(
      id: json['id'].toString(),
      conversationId: json['conversation_id'].toString(),
      senderType: senderType,
      senderId: senderId,
      message: json['message'] ?? '',
      messageType: json['message_type'] ?? 'text',
      fileUrl: json['file_url'],
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: DateTime.parse(json['created_at']),
      senderName: json['sender_name'] ?? 'Unknown',
      senderImage: json['sender_image'] ?? '',
      isMine: senderId == currentUserId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_type': senderType,
      'sender_id': senderId,
      'message': message,
      'message_type': messageType,
      'file_url': fileUrl,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'sender_name': senderName,
      'sender_image': senderImage,
      'is_mine': isMine,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? senderType,
    String? senderId,
    String? message,
    String? messageType,
    String? fileUrl,
    bool? isRead,
    DateTime? createdAt,
    String? senderName,
    String? senderImage,
    bool? isMine,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderType: senderType ?? this.senderType,
      senderId: senderId ?? this.senderId,
      message: message ?? this.message,
      messageType: messageType ?? this.messageType,
      fileUrl: fileUrl ?? this.fileUrl,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      senderName: senderName ?? this.senderName,
      senderImage: senderImage ?? this.senderImage,
      isMine: isMine ?? this.isMine,
    );
  }
}

class CallLog {
  final String id;
  final String conversationId;
  final String callerType;
  final String callerId;
  final String receiverType;
  final String receiverId;
  final String callType;
  final DateTime? startTime;
  final DateTime? endTime;
  final String status;
  final DateTime createdAt;
  final String otherUserName;
  final String otherUserImage;
  final String callDirection;
  final Duration? duration;

  CallLog({
    required this.id,
    required this.conversationId,
    required this.callerType,
    required this.callerId,
    required this.receiverType,
    required this.receiverId,
    required this.callType,
    this.startTime,
    this.endTime,
    required this.status,
    required this.createdAt,
    required this.otherUserName,
    required this.otherUserImage,
    required this.callDirection,
    this.duration,
  });

  factory CallLog.fromJson(Map<String, dynamic> json) {
    DateTime? startTime = json['start_time'] != null ? DateTime.parse(json['start_time']) : null;
    DateTime? endTime = json['end_time'] != null ? DateTime.parse(json['end_time']) : null;
    
    Duration? callDuration;
    if (startTime != null && endTime != null) {
      callDuration = endTime.difference(startTime);
    }

    return CallLog(
      id: json['id'].toString(),
      conversationId: json['conversation_id'].toString(),
      callerType: json['caller_type'] ?? '',
      callerId: json['caller_id'].toString(),
      receiverType: json['receiver_type'] ?? '',
      receiverId: json['receiver_id'].toString(),
      callType: json['call_type'] ?? 'audio',
      startTime: startTime,
      endTime: endTime,
      status: json['status'] ?? 'missed',
      createdAt: DateTime.parse(json['created_at']),
      otherUserName: json['other_name'] ?? 'Unknown',
      otherUserImage: json['other_image'] ?? '',
      callDirection: json['call_direction'] ?? 'unknown',
      duration: callDuration,
    );
  }

  String get durationString {
    if (duration == null) return '00:00';
    return '${duration!.inMinutes.toString().padLeft(2, '0')}:${(duration!.inSeconds % 60).toString().padLeft(2, '0')}';
  }
}

class Inquiry {
  final String id;
  final String conversationId;
  final String customerId;
  final String merchantId;
  final String inquiryText;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String customerName;
  final String customerImage;

  Inquiry({
    required this.id,
    required this.conversationId,
    required this.customerId,
    required this.merchantId,
    required this.inquiryText,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.customerName,
    required this.customerImage,
  });

  factory Inquiry.fromJson(Map<String, dynamic> json) {
    return Inquiry(
      id: json['id'].toString(),
      conversationId: json['conversation_id'].toString(),
      customerId: json['customer_id'].toString(),
      merchantId: json['merchant_id'].toString(),
      inquiryText: json['inquiry_text'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      customerName: json['customer_name'] ?? 'Unknown',
      customerImage: json['customer_image'] ?? '',
    );
  }
}