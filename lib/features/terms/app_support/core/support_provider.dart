// feedback_support_provider.dart
import 'package:flutter/material.dart';
import 'dart:async';

enum SupportTicketStatus { open, underReview, resolved, closed }

enum SupportTicketPriority { low, medium, high }

class SupportTicket {
  final String id;
  final String userId;
  final String subject;
  final String description;
  final DateTime createdAt;
  final List<String> attachmentUrls;
  final SupportTicketStatus status;
  final SupportTicketPriority priority;
  final List<SupportMessage> messages;

  SupportTicket({
    required this.id,
    required this.userId,
    required this.subject,
    required this.description,
    required this.createdAt,
    this.attachmentUrls = const [],
    this.status = SupportTicketStatus.open,
    this.priority = SupportTicketPriority.medium,
    this.messages = const [],
  });
}

class SupportMessage {
  final String id;
  final String ticketId;
  final String message;
  final DateTime timestamp;
  final bool isFromUser;
  final List<String> attachmentUrls;

  SupportMessage({
    required this.id,
    required this.ticketId,
    required this.message,
    required this.timestamp,
    required this.isFromUser,
    this.attachmentUrls = const [],
  });
}

class AppFeedback {
  final String id;
  final String userId;
  final double rating;
  final String comment;
  final List<String> tags;
  final DateTime submittedAt;
  final bool isAnonymous;

  AppFeedback({
    required this.id,
    required this.userId,
    required this.rating,
    this.comment = '',
    this.tags = const [],
    required this.submittedAt,
    this.isAnonymous = false,
  });
}

class FeedbackSupportProvider with ChangeNotifier {
  // User info (would typically come from user auth/profile)
  String _userId = '';
  String _userName = '';
  String _userEmail = '';

  // Support tickets
  List<SupportTicket> _userTickets = [];
  bool _isLoadingTickets = false;
  String? _ticketError;

  // Feedback
  List<AppFeedback> _userFeedback = [];
  bool _isSubmittingFeedback = false;
  String? _feedbackError;
  bool _feedbackSubmitted = false;

  // FAQ
  List<Map<String, String>> _faqs = [];
  bool _isLoadingFaqs = false;
  String? _faqError;

  // Getters
  String get userId => _userId;
  String get userName => _userName;
  String get userEmail => _userEmail;
  List<SupportTicket> get userTickets => _userTickets;
  bool get isLoadingTickets => _isLoadingTickets;
  String? get ticketError => _ticketError;
  List<AppFeedback> get userFeedback => _userFeedback;
  bool get isSubmittingFeedback => _isSubmittingFeedback;
  String? get feedbackError => _feedbackError;
  bool get feedbackSubmitted => _feedbackSubmitted;
  List<Map<String, String>> get faqs => _faqs;
  bool get isLoadingFaqs => _isLoadingFaqs;
  String? get faqError => _faqError;

  // Set user info
  void setUserInfo(String userId, String userName, String userEmail) {
    _userId = userId;
    _userName = userName;
    _userEmail = userEmail;
    notifyListeners();
  }

  // Reset the feedback submission state
  void resetFeedbackState() {
    _feedbackSubmitted = false;
    _feedbackError = null;
    notifyListeners();
  }

  // Load user support tickets
  Future<void> loadUserTickets() async {
    if (_userId.isEmpty) {
      _ticketError = 'User not authenticated';
      notifyListeners();
      return;
    }

    _isLoadingTickets = true;
    _ticketError = null;
    notifyListeners();

    try {
      // Simulate API call with delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock data - in a real app, this would fetch from your API
      _userTickets = [
        SupportTicket(
          id: 'ticket_001',
          userId: _userId,
          subject: 'Payment issue',
          description: 'I was charged twice for the same service.',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          status: SupportTicketStatus.underReview,
          priority: SupportTicketPriority.high,
          messages: [
            SupportMessage(
              id: 'msg_001',
              ticketId: 'ticket_001',
              message: 'I was charged twice for the same service on March 15.',
              timestamp: DateTime.now().subtract(const Duration(days: 2)),
              isFromUser: true,
            ),
            SupportMessage(
              id: 'msg_002',
              ticketId: 'ticket_001',
              message:
                  'Thank you for reporting this issue. We are investigating the double charge and will get back to you shortly.',
              timestamp: DateTime.now().subtract(
                const Duration(days: 1, hours: 4),
              ),
              isFromUser: false,
            ),
          ],
        ),
        SupportTicket(
          id: 'ticket_002',
          userId: _userId,
          subject: 'App crashing on startup',
          description: 'The app crashes immediately when I try to open it.',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          status: SupportTicketStatus.resolved,
          priority: SupportTicketPriority.medium,
          messages: [
            SupportMessage(
              id: 'msg_003',
              ticketId: 'ticket_002',
              message:
                  'The app crashes immediately when I try to open it on my iPhone 13.',
              timestamp: DateTime.now().subtract(const Duration(days: 5)),
              isFromUser: true,
            ),
            SupportMessage(
              id: 'msg_004',
              ticketId: 'ticket_002',
              message:
                  "We\'ve identified the issue and will be releasing an update within 24 hours. In the meantime, try clearing the app cache.",
              timestamp: DateTime.now().subtract(const Duration(days: 4)),
              isFromUser: false,
            ),
            SupportMessage(
              id: 'msg_005',
              ticketId: 'ticket_002',
              message:
                  'Thanks, clearing the cache worked! Looking forward to the update.',
              timestamp: DateTime.now().subtract(
                const Duration(days: 3, hours: 12),
              ),
              isFromUser: true,
            ),
          ],
        ),
      ];

      _isLoadingTickets = false;
      notifyListeners();
    } catch (e) {
      _isLoadingTickets = false;
      _ticketError = 'Failed to load support tickets: ${e.toString()}';
      notifyListeners();
    }
  }

  // Create a new support ticket
  Future<bool> createSupportTicket(
    String subject,
    String description,
    List<String> attachments,
    SupportTicketPriority priority,
  ) async {
    if (_userId.isEmpty) {
      _ticketError = 'User not authenticated';
      notifyListeners();
      return false;
    }

    _isLoadingTickets = true;
    _ticketError = null;
    notifyListeners();

    try {
      // Simulate API call with delay
      await Future.delayed(const Duration(seconds: 2));

      // Create a new ticket (mock implementation)
      final newTicket = SupportTicket(
        id: 'ticket_${DateTime.now().millisecondsSinceEpoch}',
        userId: _userId,
        subject: subject,
        description: description,
        createdAt: DateTime.now(),
        attachmentUrls: attachments,
        priority: priority,
        messages: [
          SupportMessage(
            id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
            ticketId: 'ticket_${DateTime.now().millisecondsSinceEpoch}',
            message: description,
            timestamp: DateTime.now(),
            isFromUser: true,
            attachmentUrls: attachments,
          ),
        ],
      );

      // Add to local list
      _userTickets.insert(0, newTicket);

      _isLoadingTickets = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoadingTickets = false;
      _ticketError = 'Failed to create support ticket: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Add a reply to an existing ticket
  Future<bool> addTicketReply(
    String ticketId,
    String message,
    List<String> attachments,
  ) async {
    if (_userId.isEmpty) {
      _ticketError = 'User not authenticated';
      notifyListeners();
      return false;
    }

    _isLoadingTickets = true;
    _ticketError = null;
    notifyListeners();

    try {
      // Simulate API call with delay
      await Future.delayed(const Duration(seconds: 1));

      // Find the ticket
      final ticketIndex = _userTickets.indexWhere(
        (ticket) => ticket.id == ticketId,
      );
      if (ticketIndex == -1) {
        throw Exception('Ticket not found');
      }

      // Create a new message
      final newMessage = SupportMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        ticketId: ticketId,
        message: message,
        timestamp: DateTime.now(),
        isFromUser: true,
        attachmentUrls: attachments,
      );

      // Create a new ticket object with the updated messages list
      final updatedTicket = SupportTicket(
        id: _userTickets[ticketIndex].id,
        userId: _userTickets[ticketIndex].userId,
        subject: _userTickets[ticketIndex].subject,
        description: _userTickets[ticketIndex].description,
        createdAt: _userTickets[ticketIndex].createdAt,
        attachmentUrls: _userTickets[ticketIndex].attachmentUrls,
        status: _userTickets[ticketIndex].status,
        priority: _userTickets[ticketIndex].priority,
        messages: [..._userTickets[ticketIndex].messages, newMessage],
      );

      // Update the ticket in the list
      _userTickets[ticketIndex] = updatedTicket;

      _isLoadingTickets = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoadingTickets = false;
      _ticketError = 'Failed to add reply: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Close a support ticket
  Future<bool> closeTicket(String ticketId) async {
    if (_userId.isEmpty) {
      _ticketError = 'User not authenticated';
      notifyListeners();
      return false;
    }

    _isLoadingTickets = true;
    _ticketError = null;
    notifyListeners();

    try {
      // Simulate API call with delay
      await Future.delayed(const Duration(seconds: 1));

      // Find the ticket
      final ticketIndex = _userTickets.indexWhere(
        (ticket) => ticket.id == ticketId,
      );
      if (ticketIndex == -1) {
        throw Exception('Ticket not found');
      }

      // Create a new ticket object with closed status
      final updatedTicket = SupportTicket(
        id: _userTickets[ticketIndex].id,
        userId: _userTickets[ticketIndex].userId,
        subject: _userTickets[ticketIndex].subject,
        description: _userTickets[ticketIndex].description,
        createdAt: _userTickets[ticketIndex].createdAt,
        attachmentUrls: _userTickets[ticketIndex].attachmentUrls,
        status: SupportTicketStatus.closed,
        priority: _userTickets[ticketIndex].priority,
        messages: _userTickets[ticketIndex].messages,
      );

      // Update the ticket in the list
      _userTickets[ticketIndex] = updatedTicket;

      _isLoadingTickets = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoadingTickets = false;
      _ticketError = 'Failed to close ticket: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Submit app feedback
  Future<bool> submitAppFeedback(
    double rating,
    String comment,
    List<String> tags,
    bool isAnonymous,
  ) async {
    if (_userId.isEmpty && !isAnonymous) {
      _feedbackError = 'User not authenticated';
      notifyListeners();
      return false;
    }

    _isSubmittingFeedback = true;
    _feedbackError = null;
    _feedbackSubmitted = false;
    notifyListeners();

    try {
      // Simulate API call with delay
      await Future.delayed(const Duration(seconds: 2));

      // Create new feedback object
      final newFeedback = AppFeedback(
        id: 'feedback_${DateTime.now().millisecondsSinceEpoch}',
        userId: isAnonymous ? 'anonymous' : _userId,
        rating: rating,
        comment: comment,
        tags: tags,
        submittedAt: DateTime.now(),
        isAnonymous: isAnonymous,
      );

      // Add to local list
      _userFeedback.insert(0, newFeedback);

      _isSubmittingFeedback = false;
      _feedbackSubmitted = true;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmittingFeedback = false;
      _feedbackError = 'Failed to submit feedback: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Load FAQs
  Future<void> loadFaqs() async {
    _isLoadingFaqs = true;
    _faqError = null;
    notifyListeners();

    try {
      // Simulate API call with delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - in a real app, this would fetch from your API
      _faqs = [
        {
          'question': 'How do I create a new service request?',
          'answer':
              'To create a new service request, navigate to the home screen and tap on the "New Request" button. Then follow the on-screen instructions to select the service type, provide details, and submit your request.',
        },
        {
          'question': "How do I track my service provider\'s location?",
          'answer':
              'Once a service provider accepts your request and is en route, you can track their location in real-time by opening your active request and tapping on the "Track Provider" button.',
        },
        {
          'question': 'How do I pay for services?',
          'answer':
              "You can pay for services using the payment methods saved in your account. After the service is completed, you\'ll receive a payment request. You can also enable auto-payment in your account settings.",
        },
        {
          'question': 'Can I cancel a service request?',
          'answer':
              'Yes, you can cancel a service request at any time before the provider arrives. Just open the active request and tap on "Cancel Request". Note that cancellation fees may apply depending on how close to the scheduled time you cancel.',
        },
        {
          'question': 'How do I become a service provider?',
          'answer':
              "To become a service provider, tap on the menu and select 'Become a Provider'. You\'ll need to complete an application form, submit required documentation, and pass a background check before you can start accepting service requests.",
        },
      ];

      _isLoadingFaqs = false;
      notifyListeners();
    } catch (e) {
      _isLoadingFaqs = false;
      _faqError = 'Failed to load FAQs: ${e.toString()}';
      notifyListeners();
    }
  }
}
