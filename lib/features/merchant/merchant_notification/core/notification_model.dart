// notification_model.dart
import 'package:flutter/material.dart';

/// Model representing a single notification
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final MerchantNotificationType type;
  final bool isRead;
  final String? actionLink;
  final Map<String, dynamic>? additionalData;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.actionLink,
    this.additionalData,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    MerchantNotificationType? type,
    bool? isRead,
    String? actionLink,
    Map<String, dynamic>? additionalData,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      actionLink: actionLink ?? this.actionLink,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}

/// Enum representing different types of notifications
enum MerchantNotificationType {
  info,
  success,
  warning,
  error,
  transaction,
  serviceUpdate,
  accountUpdate,
  promotion,
}

extension NotificationTypeExtension on MerchantNotificationType {
  IconData get icon {
    switch (this) {
      case MerchantNotificationType.info:
        return Icons.info_outline;
      case MerchantNotificationType.success:
        return Icons.check_circle_outline;
      case MerchantNotificationType.warning:
        return Icons.warning_amber_outlined;
      case MerchantNotificationType.error:
        return Icons.error_outline;
      case MerchantNotificationType.transaction:
        return Icons.receipt_long;
      case MerchantNotificationType.serviceUpdate:
        return Icons.update;
      case MerchantNotificationType.accountUpdate:
        return Icons.person_outline;
      case MerchantNotificationType.promotion:
        return Icons.local_offer_outlined;
    }
  }

  Color getColor(ThemeData theme) {
    switch (this) {
      case MerchantNotificationType.info:
        return theme.colorScheme.primary;
      case MerchantNotificationType.success:
        return Colors.green;
      case MerchantNotificationType.warning:
        return Colors.orange;
      case MerchantNotificationType.error:
        return theme.colorScheme.error;
      case MerchantNotificationType.transaction:
        return Colors.blue;
      case MerchantNotificationType.serviceUpdate:
        return Colors.purple;
      case MerchantNotificationType.accountUpdate:
        return Colors.teal;
      case MerchantNotificationType.promotion:
        return Colors.amber;
    }
  }
}
