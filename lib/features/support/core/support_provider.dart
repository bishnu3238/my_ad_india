import 'package:flutter/material.dart';
import 'support_state.dart';

class SupportProvider extends ChangeNotifier {
  SupportState _state = SupportState();
  SupportState get state => _state;

  void updateTitle(String title) {
    _state = _state.copyWith(title: title);
    notifyListeners();
  }

  void updateDescription(String description) {
    _state = _state.copyWith(description: description);
    notifyListeners();
  }

  void updatePriority(SupportTicketPriority priority) {
    _state = _state.copyWith(priority: priority);
    notifyListeners();
  }

  Future<void> submitTicket() async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      final newTicket = SupportTicket(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _state.title,
        description: _state.description,
        createdAt: DateTime.now(),
        status: SupportTicketStatus.open,
        priority: _state.priority,
      );

      final updatedTickets = [..._state.tickets, newTicket];

      _state = _state.copyWith(
        isLoading: false,
        tickets: updatedTickets,
        title: '',
        description: '',
        priority: SupportTicketPriority.low,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: 'Failed to submit ticket: ${e.toString()}',
      );
      notifyListeners();
    }
  }
}
