// notification_counter_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/notification_service.dart';


/// Widget to display the notification counter badge in the app bar
class NotificationCounterWidget extends StatefulWidget {
  final Color? badgeColor;
  final Color? iconColor;
  final VoidCallback onPressed;

  const NotificationCounterWidget({
    super.key,
    this.badgeColor,
    this.iconColor,
    required this.onPressed,
  });

  @override
  State<NotificationCounterWidget> createState() => _NotificationCounterWidgetState();
}

class _NotificationCounterWidgetState extends State<NotificationCounterWidget> {
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _updateCount();
  }

  Future<void> _updateCount() async {
    final service = Provider.of<NotificationService>(context, listen: false);
    final count = await service.getUnreadCount();

    if (mounted) {
      setState(() {
        _count = count;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: widget.iconColor ?? theme.onSurface,
          ),
          onPressed: () {
            widget.onPressed();
            // Reset counter after viewing notifications
            setState(() {
              _count = 0;
            });
          },
        ),
        if (_count > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: widget.badgeColor ?? theme.error,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.surface,
                  width: 1.5,
                ),
              ),
              constraints: BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Center(
                child: Text(
                  _count > 9 ? '9+' : '$_count',
                  style: TextStyle(
                    color: theme.onError,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}