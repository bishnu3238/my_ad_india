import 'dart:convert';

class Conversation {
  final int id;
  final int customerId;
  final int merchantId;
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
      id: json['id'],
      customerId: json['customer_id'],
      merchantId: json['merchant_id'],
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
  final int id;
  final int conversationId;
  final String senderType;
  final int senderId;
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

  factory ChatMessage.fromJson(Map<String, dynamic> json, String currentUserType, int currentUserId) {
    return ChatMessage(
      id: json['id'],
      conversationId: json['conversation_id'],
      senderType: json['sender_type'],
      senderId: json['sender_id'],
      message: json['message'],
      messageType: json['message_type'],
      fileUrl: json['file_url'],
      isRead: json['is_read'] == 1,
      createdAt: DateTime.parse(json['created_at']),
      senderName: json['sender_name'] ?? 'Unknown',
      senderImage: json['sender_image'] ?? '',
      isMine: json['sender_type'] == currentUserType && json['sender_id'] == currentUserId,
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

  // Create a new message for sending
  static Map<String, dynamic> createMessage({
    required int conversationId,
    required String senderType,
    required int senderId,
    required String receiverType,
    required int receiverId,
    required String message,
    String messageType = 'text',
    String? fileUrl,
  }) {
    return {
      'conversationId': conversationId,
      'senderType': senderType,
      'senderId': senderId,
      'receiverType': receiverType,
      'receiverId': receiverId,
      'message': message,
      'messageType': messageType,
      'fileUrl': fileUrl,
    };
  }
}

class CallLog {
  final int id;
  final int conversationId;
  final String callerType;
  final int callerId;
  final String receiverType;
  final int receiverId;
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
      id: json['id'],
      conversationId: json['conversation_id'],
      callerType: json['caller_type'],
      callerId: json['caller_id'],
      receiverType: json['receiver_type'],
      receiverId: json['receiver_id'],
      callType: json['call_type'],
      startTime: startTime,
      endTime: endTime,
      status: json['status'],
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'caller_type': callerType,
      'caller_id': callerId,
      'receiver_type': receiverType,
      'receiver_id': receiverId,
      'call_type': callType,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'other_user_name': otherUserName,
      'other_user_image': otherUserImage,
      'call_direction': callDirection,
      'duration': durationString,
    };
  }
}

class Inquiry {
  final int id;
  final int conversationId;
  final int customerId;
  final int merchantId;
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
      id: json['id'],
      conversationId: json['conversation_id'],
      customerId: json['customer_id'],
      merchantId: json['merchant_id'],
      inquiryText: json['inquiry_text'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      customerName: json['customer_name'] ?? 'Unknown',
      customerImage: json['customer_image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'customer_id': customerId,
      'merchant_id': merchantId,
      'inquiry_text': inquiryText,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'customer_name': customerName,
      'customer_image': customerImage,
    };
  }
}