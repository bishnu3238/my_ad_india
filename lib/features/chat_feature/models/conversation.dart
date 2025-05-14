import 'package:equatable/equatable.dart';

class Conversation extends Equatable {
  final int id;
  final int customerId;
  final int merchantId;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? customerName;
  final String? customerImage;
  final String? merchantName;
  final String? merchantImage;
  final int? unreadCount;

  const Conversation({
    required this.id,
    required this.customerId,
    required this.merchantId,
    this.lastMessage,
    this.lastMessageTime,
    this.createdAt,
    this.updatedAt,
    this.customerName,
    this.customerImage,
    this.merchantName,
    this.merchantImage,
    this.unreadCount,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json['id'],
    customerId: json['customer_id'],
    merchantId: json['merchant_id'],
    lastMessage: json['last_message'],
    lastMessageTime:
        json['last_message_time'] != null
            ? DateTime.parse(json['last_message_time'])
            : null,
    createdAt:
        json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    updatedAt:
        json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    customerName: json['customer_name'],
    customerImage: json['customer_image'],
    merchantName: json['merchant_name'],
    merchantImage: json['merchant_image'],
    unreadCount: json['unread_count'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'customer_id': customerId,
    'merchant_id': merchantId,
    'last_message': lastMessage,
    'last_message_time': lastMessageTime?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'customer_name': customerName,
    'customer_image': customerImage,
    'merchant_name': merchantName,
    'merchant_image': merchantImage,
    'unread_count': unreadCount,
  };

  @override
  String toString() {
    return 'Conversation{id: $id, customerId: $customerId, merchantId: $merchantId, lastMessage: $lastMessage, lastMessageTime: $lastMessageTime, createdAt: $createdAt, updatedAt: $updatedAt, customerName: $customerName, customerImage: $customerImage, merchantName: $merchantName, merchantImage: $merchantImage, unreadCount: $unreadCount}';
  }

  Conversation copyWith({
    int? id,
    int? customerId,
    int? merchantId,
    String? lastMessage,
    DateTime? lastMessageTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? customerName,
    String? customerImage,
    String? merchantName,
    String? merchantImage,
    int? unreadCount,
  }) => Conversation(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    merchantId: merchantId ?? this.merchantId,
    lastMessage: lastMessage ?? this.lastMessage,
    lastMessageTime: lastMessageTime ?? this.lastMessageTime,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    customerName: customerName ?? this.customerName,
    customerImage: customerImage ?? this.customerImage,
    merchantName: merchantName ?? this.merchantName,
    merchantImage: merchantImage ?? this.merchantImage,
    unreadCount: unreadCount ?? this.unreadCount,
  );

  static const Conversation empty = Conversation(
    id: 0,
    customerId: 0,
    merchantId: 0,
    lastMessage: null,
    lastMessageTime: null,
    createdAt: null,
    updatedAt: null,
    customerName: null,
    customerImage: null,
    merchantName: null,
    merchantImage: null,
    unreadCount: 0,
  );

  @override
  List<Object?> get props => [
    id,
    customerId,
    merchantId,
    lastMessage,
    lastMessageTime,
    createdAt,
    updatedAt,
    customerName,
    customerImage,
    merchantName,
    merchantImage,
    unreadCount,
  ];
}
