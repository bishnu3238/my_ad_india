// notification_page.dart
import 'package:flutter/material.dart';
 import 'package:intl/intl.dart';
import 'package:pack/constant/constant.dart';
import 'package:provider/provider.dart';
// import 'package:timeago/timeago.dart' as timeago;

import '../../../core/domain/data_store/merchant_dashboard_store.dart';
 import 'core/notification_model.dart';
import 'core/notification_provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Set up scroll listener for pagination
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // We're near the bottom, load more data
      final provider = Provider.of<NotificationProvider>(context, listen: false);
      final merchantId = Provider.of<MerchantDashboardStore>(context, listen: false)
          .entity?.merchantData.merchant.id ?? '';

      provider.loadMore('$merchantId');
    }
  }

  Future<void> _initData() async {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    final merchantId = Provider.of<MerchantDashboardStore>(context, listen: false)
        .entity?.merchantData.merchant.id ?? '';

    await provider.initNotifications('$merchantId');
  }

  Future<void> _refresh() async {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    final merchantId = Provider.of<MerchantDashboardStore>(context, listen: false)
        .entity?.merchantData.merchant.id ?? '';

    await provider.fetchNotifications('$merchantId', refresh: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications", style: textTheme.titleLarge),
        actions: [
          IconButton(
            icon: Icon(Icons.done_all),
            tooltip: "Mark all as read",
            onPressed: () {
              final provider = Provider.of<NotificationProvider>(context, listen: false);
              provider.markAllAsRead();
            },
          ),
          // Add filtering options
          PopupMenuButton<NotificationFilter>(
            icon: Icon(Icons.filter_list),
            tooltip: "Filter notifications",
            onSelected: (filter) {
              final provider = Provider.of<NotificationProvider>(context, listen: false);
              provider.setFilter(filter);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: NotificationFilter.all,
                child: Text("All Notifications"),
              ),
              PopupMenuItem(
                value: NotificationFilter.unread,
                child: Text("Unread"),
              ),
              PopupMenuItem(
                value: NotificationFilter.read,
                child: Text("Read"),
              ),
              PopupMenuItem(
                value: NotificationFilter.transaction,
                child: Text("Transactions"),
              ),
              PopupMenuItem(
                value: NotificationFilter.serviceUpdate,
                child: Text("Service Updates"),
              ),
              PopupMenuItem(
                value: NotificationFilter.accountUpdate,
                child: Text("Account Updates"),
              ),
              PopupMenuItem(
                value: NotificationFilter.promotion,
                child: Text("Promotions"),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return _buildLoadingState();
          }

          if (provider.errorMessage != null && provider.notifications.isEmpty) {
            return _buildErrorState(provider.errorMessage!);
          }

          if (provider.notifications.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: _buildNotificationList(provider),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("Loading notifications...")
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red),
          SizedBox(height: 16),
          Text(
            "Oops! Something went wrong",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refresh,
            child: Text("Try Again"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No Notifications",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 8),
          Text(
            "You're all caught up! No new notifications.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refresh,
            child: Text("Refresh"),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(NotificationProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(vertical: 8),
      itemCount: provider.notifications.length + (provider.hasMoreNotifications ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator at the bottom when loading more
        if (index == provider.notifications.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final notification = provider.notifications[index];
        return _buildNotificationItem(notification, provider);
      },
    );
  }

  Widget _buildNotificationItem(NotificationModel notification, NotificationProvider provider) {
    final theme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final timeStr = _formatTime(notification.timestamp);

    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Delete Notification"),
              content: Text("Are you sure you want to delete this notification?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text("Delete", style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        provider.deleteNotification(notification.id);

        // Show snackbar with undo option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Notification deleted"),
            action: SnackBarAction(
              label: "Undo",
              onPressed: () {
                // In a real app, you would implement an undo feature
                _refresh();
              },
            ),
          ),
        );
      },
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            provider.markAsRead(notification.id);
          }

          // Show the full notification in a bottom sheet
          _showNotificationDetails(notification);
        },
        child: Container(
          color: notification.isRead ? null : theme.primaryContainer.withOpacity(0.1),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon indicator based on notification type
              Container(
                decoration: BoxDecoration(
                  color: notification.type.getColor(Theme.of(context)).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(8),
                child: Icon(
                  notification.type.icon,
                  color: notification.type.getColor(Theme.of(context)),
                  size: 24,
                ),
              ),
              SizedBox(width: 16),

              // Notification content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          timeStr,
                          style: textTheme.bodySmall?.copyWith(
                            color: theme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: textTheme.bodyMedium?.copyWith(
                        color: theme.onSurface.withOpacity(0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Action button if applicable
                    if (notification.actionLink != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                if (!notification.isRead) {
                                  provider.markAsRead(notification.id);
                                }
                                // Navigate to the action link
                                // TODO: Implement navigation based on actionLink
                                print('Navigate to: ${notification.actionLink}');
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                minimumSize: Size(0, 30),
                              ),
                              child: Text('View Details'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Unread indicator
              if (!notification.isRead)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: theme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 7) {
      return DateFormat('MMM dd').format(time);
    } else {
      // return timeago.format(time, locale: 'en_short');
      return time.timeAgo;
    }
  }

  void _showNotificationDetails(NotificationModel notification) {
    final theme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottom sheet header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: notification.type.getColor(Theme.of(context)).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          notification.type.icon,
                          color: notification.type.getColor(Theme.of(context)),
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        notification.title,
                        style: textTheme.titleLarge,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              Divider(height: 24),

              // Notification time
              Row(
                children: [
                  Icon(Icons.access_time, size: 18, color: theme.onSurface.withOpacity(0.6)),
                  SizedBox(width: 8),
                  Text(
                    DateFormat('MMMM dd, yyyy - h:mm a').format(notification.timestamp),
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Notification message
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    notification.message,
                    style: textTheme.bodyLarge,
                  ),
                ),
              ),

              // Additional data if available
              if (notification.additionalData != null && notification.additionalData!.isNotEmpty)
                _buildAdditionalData(notification.additionalData!),

              SizedBox(height: 16),

              // Action button if applicable
              if (notification.actionLink != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to the action link
                      // TODO: Implement navigation based on actionLink
                      print('Navigate to: ${notification.actionLink}');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: theme.primary,
                      foregroundColor: theme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _getActionButtonText(notification.type),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdditionalData(Map<String, dynamic> data) {
    final theme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Additional Information",
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          ...data.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Text(
                    "${_capitalizeFirstLetter(entry.key)}: ",
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${entry.value}",
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _getActionButtonText(MerchantNotificationType type) {
    switch (type) {
      case MerchantNotificationType.info:
        return "View Details";
      case MerchantNotificationType.success:
        return "View Details";
      case MerchantNotificationType.warning:
        return "Take Action";
      case MerchantNotificationType.error:
        return "Resolve Issue";
      case MerchantNotificationType.transaction:
        return "View Transaction";
      case MerchantNotificationType.serviceUpdate:
        return "Update Service";
      case MerchantNotificationType.accountUpdate:
        return "Update Account";
      case MerchantNotificationType.promotion:
        return "Get Offer";
    }
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}