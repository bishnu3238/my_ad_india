import 'package:equatable/equatable.dart';

class Call extends Equatable {
  final int id;
  final int conversationId;
  final String callerType;
  final int callerId;
  final String receiverType;
  final int receiverId;
  final String callType;
  final String status;
  final DateTime? startTime;
  final DateTime? answerTime;
  final DateTime? endTime;
  final int? duration;
  final String? callerName;
  final String? callerImage;
  final String? receiverName;
  final String? receiverImage;
  final DateTime? createdAt;

  const Call({
    required this.id,
    required this.conversationId,
    required this.callerType,
    required this.callerId,
    required this.receiverType,
    required this.receiverId,
    required this.callType,
    required this.status,
    this.startTime,
    this.answerTime,
    this.endTime,
    this.duration,
    this.callerName,
    this.callerImage,
    this.receiverName,
    this.receiverImage,
    this.createdAt,
  });

  factory Call.fromJson(Map<String, dynamic> json) => Call(
    id: json['id'],
    conversationId: json['conversation_id'],
    callerType: json['caller_type'],
    callerId: json['caller_id'],
    receiverType: json['receiver_type'],
    receiverId: json['receiver_id'],
    callType: json['call_type'],
    status: json['status'],
    startTime:
        json['start_time'] != null ? DateTime.parse(json['start_time']) : null,
    answerTime:
        json['answer_time'] != null
            ? DateTime.parse(json['answer_time'])
            : null,
    endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
    duration: json['duration'],
    callerName: json['caller_name'],
    callerImage: json['caller_image'],
    receiverName: json['receiver_name'],
    receiverImage: json['receiver_image'],
    createdAt:
        json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'conversation_id': conversationId,
    'caller_type': callerType,
    'caller_id': callerId,
    'receiver_type': receiverType,
    'receiver_id': receiverId,
    'call_type': callType,
    'status': status,
    'start_time': startTime?.toIso8601String(),
    'answer_time': answerTime?.toIso8601String(),
    'end_time': endTime?.toIso8601String(),
    'duration': duration,
    'caller_name': callerName,
    'caller_image': callerImage,
    'receiver_name': receiverName,
    'receiver_image': receiverImage,
    'created_at': createdAt?.toIso8601String(),
  };

  @override
  String toString() {
    return 'Call{id: $id, conversationId: $conversationId, callerType: $callerType, callerId: $callerId, receiverType: $receiverType, receiverId: $receiverId, callType: $callType, status: $status, startTime: $startTime, answerTime: $answerTime, endTime: $endTime, duration: $duration, callerName: $callerName, callerImage: $callerImage, receiverName: $receiverName, receiverImage: $receiverImage, createdAt: $createdAt}';
  }

  Call copyWith({
    int? id,
    int? conversationId,
    String? callerType,
    int? callerId,
    String? receiverType,
    int? receiverId,
    String? callType,
    String? status,
    DateTime? startTime,
    DateTime? answerTime,
    DateTime? endTime,
    int? duration,
    String? callerName,
    String? callerImage,
    String? receiverName,
    String? receiverImage,
    DateTime? createdAt,
  }) => Call(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    callerType: callerType ?? this.callerType,
    callerId: callerId ?? this.callerId,
    receiverType: receiverType ?? this.receiverType,
    receiverId: receiverId ?? this.receiverId,
    callType: callType ?? this.callType,
    status: status ?? this.status,
    startTime: startTime ?? this.startTime,
    answerTime: answerTime ?? this.answerTime,
    endTime: endTime ?? this.endTime,
    duration: duration ?? this.duration,
    callerName: callerName ?? this.callerName,
    callerImage: callerImage ?? this.callerImage,
    receiverName: receiverName ?? this.receiverName,
    receiverImage: receiverImage ?? this.receiverImage,
    createdAt: createdAt ?? this.createdAt,
  );

  static const Call empty = const Call(
    id: 0,
    conversationId: 0,
    callerType: '',
    callerId: 0,
    receiverType: '',
    receiverId: 0,
    callType: '',
    status: '',
    startTime: null,
    answerTime: null,
    endTime: null,
    duration: null,
    callerName: null,
    callerImage: null,
    receiverName: null,
    receiverImage: null,
    createdAt: null,
  );

  @override
  List<Object?> get props => [
    id,
    conversationId,
    callerType,
    callerId,
    receiverType,
    receiverId,
    callType,
    status,
    startTime,
    answerTime,
    endTime,
    duration,
    callerName,
    callerImage,
    receiverName,
    receiverImage,
    createdAt,
  ];
}
