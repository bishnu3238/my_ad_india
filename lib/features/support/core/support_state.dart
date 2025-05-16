import 'package:flutter/foundation.dart';

enum SupportTicketPriority { low, medium, high }
enum SupportTicketStatus { open, inProgress, resolved }

@immutable
class SupportState {
  final String title;
  final String description;
  final SupportTicketPriority priority;
  final bool isLoading;
  final String? error;
  final List<SupportTicket> tickets;

  const SupportState({
    this.title = '',
    this.description = '',
    this.priority = SupportTicketPriority.low,
    this.isLoading = false,
    this.error,
    this.tickets = const [],
  });

  SupportState copyWith({
    String? title,
    String? description,
    SupportTicketPriority? priority,
    bool? isLoading,
    String? error,
    List<SupportTicket>? tickets,
  }) {
    return SupportState(
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      tickets: tickets ?? this.tickets,
    );
  }
}

class SupportTicket {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final SupportTicketStatus status;
  final SupportTicketPriority priority;

  SupportTicket({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.status,
    required this.priority,
  });
}
