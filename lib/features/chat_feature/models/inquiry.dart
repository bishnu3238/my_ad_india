import 'package:equatable/equatable.dart';

class Inquiry  extends Equatable{
  final int id;
  final int conversationId;
  final int customerId;
  final int merchantId;
  final String subject;
  final String message;
  final String? attachmentUrl;
  final String status;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? customerName;
  final String? customerImage;
  final String? merchantName;
  final String? merchantImage;

  Inquiry({
    required this.id,
    required this.conversationId,
    required this.customerId,
    required this.merchantId,
    required this.subject,
    required this.message,
    this.attachmentUrl,
    required this.status,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.customerName,
    this.customerImage,
    this.merchantName,
    this.merchantImage,
  });

  factory Inquiry.fromJson(Map<String, dynamic> json) => Inquiry(
    id: json['id'],
    conversationId: json['conversation_id'],
    customerId: json['customer_id'],
    merchantId: json['merchant_id'],
    subject: json['subject'],
    message: json['message'],
    attachmentUrl: json['attachment_url'],
    status: json['status'],
    notes: json['notes'],
    createdAt:
        json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    updatedAt:
        json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    customerName: json['customer_name'],
    customerImage: json['customer_image'],
    merchantName: json['merchant_name'],
    merchantImage: json['merchant_image'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'conversation_id': conversationId,
    'customer_id': customerId,
    'merchant_id': merchantId,
    'subject': subject,
    'message': message,
    'attachment_url': attachmentUrl,
    'status': status,
    'notes': notes,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'customer_name': customerName,
    'customer_image': customerImage,
    'merchant_name': merchantName,
    'merchant_image': merchantImage,
  };

  @override
  String toString() {
    return 'Inquiry{id: $id, conversationId: $conversationId, customerId: $customerId, merchantId: $merchantId, subject: $subject, message: $message, attachmentUrl: $attachmentUrl, status: $status, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, customerName: $customerName, customerImage: $customerImage, merchantName: $merchantName, merchantImage: $merchantImage}';
  }

  Inquiry copyWith({
    int? id,
    int? conversationId,
    int? customerId,
    int? merchantId,
    String? subject,
    String? message,
    String? attachmentUrl,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? customerName,
    String? customerImage,
    String? merchantName,
    String? merchantImage,
  }) {
    return Inquiry(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      customerId: customerId ?? this.customerId,
      merchantId: merchantId ?? this.merchantId,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customerName: customerName ?? this.customerName,
      customerImage: customerImage ?? this.customerImage,
      merchantName: merchantName ?? this.merchantName,
      merchantImage: merchantImage ?? this.merchantImage,
    );
  }

  static Inquiry empty = Inquiry(
    id: 0,
    conversationId: 0,
    customerId: 0,
    merchantId: 0,
    subject: '',
    message: '',
    attachmentUrl: null,
    status: '',
    notes: null,
    createdAt: null,
    updatedAt: null,
    customerName: null,
    customerImage: null,
    merchantName: null,
    merchantImage: null,
  );


  @override
  List<Object?> get props => [
    id,
    conversationId,
    customerId,
    merchantId,
    subject,
    message,
    attachmentUrl,
    status,
    notes,
    createdAt,
    updatedAt,
    customerName,
    customerImage,
    merchantName,
    merchantImage
  ];
}
