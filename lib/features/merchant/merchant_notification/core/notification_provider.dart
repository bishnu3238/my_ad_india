// notification_provider.dart
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:pack/services/service.dart';
import 'notification_model.dart';
import 'notification_service.dart';

enum NotificationFilter {
  all,
  unread,
  read,
  transaction,
  serviceUpdate,
  accountUpdate,
  promotion,
}

/// State management for notifications page
class NotificationProvider extends BaseProviderModel {
  final NotificationService _notificationService;
  List<NotificationModel> _notifications = [];
  NotificationFilter _currentFilter = NotificationFilter.all;
  bool _isRefreshing = false;
  String? _errorMessage;
  bool _hasMoreNotifications = true;
  int _currentPage = 1;

  NotificationProvider(this._notificationService);

  // Getters
  List<NotificationModel> get notifications => _getFilteredNotifications();
  NotificationFilter get currentFilter => _currentFilter;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  bool get hasMoreNotifications => _hasMoreNotifications;

  // Get notifications count by type
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  int get readCount => _notifications.where((n) => n.isRead).length;
  int get totalCount => _notifications.length;

  // Filter notifications based on the current filter
  List<NotificationModel> _getFilteredNotifications() {
    switch (_currentFilter) {
      case NotificationFilter.all:
        return _notifications;
      case NotificationFilter.unread:
        return _notifications.where((n) => !n.isRead).toList();
      case NotificationFilter.read:
        return _notifications.where((n) => n.isRead).toList();
      case NotificationFilter.transaction:
        return _notifications.where((n) => n.type == MerchantNotificationType.transaction).toList();
      case NotificationFilter.serviceUpdate:
        return _notifications.where((n) => n.type == MerchantNotificationType.serviceUpdate).toList();
      case NotificationFilter.accountUpdate:
        return _notifications.where((n) => n.type == MerchantNotificationType.accountUpdate).toList();
      case NotificationFilter.promotion:
        return _notifications.where((n) => n.type == MerchantNotificationType.promotion).toList();
    }
  }

  // Set filter and refresh notifications view
  void setFilter(NotificationFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  // Initialize notifications
  Future<void> initNotifications(String merchantId) async {
    _currentPage = 1;
    _hasMoreNotifications = true;
    await fetchNotifications(merchantId);
  }

  // Fetch notifications
  Future<void> fetchNotifications(String merchantId, {bool refresh = false}) async {
    try {
      if (refresh) {
        _isRefreshing = true;
        _currentPage = 1;
        notifyListeners();
      } else if (!_hasMoreNotifications) {
        // No more notifications to fetch
        return;
      } else {
        setLoading();
      }

      final newNotifications = await _notificationService.fetchNotifications(
        merchantId: merchantId,
        page: _currentPage,
        forceRefresh: refresh,
      );

      if (refresh || _currentPage == 1) {
        _notifications = newNotifications;
      } else {
        // Append to existing notifications for pagination
        _notifications = [..._notifications, ...newNotifications];
      }

      // Check if we've reached the end of the notifications
      _hasMoreNotifications = newNotifications.length >= 20; // Assuming 20 is our limit
      _currentPage++;
      _errorMessage = null;

      setData<bool>(true);
    } catch (e) {
      dev.log('Error in fetchNotifications: $e');
      _errorMessage = 'Failed to load notifications: $e';
      setException(ErrorState.network('$e', retryCallback: () => fetchNotifications(merchantId)));
    } finally {
      if (refresh) {
        _isRefreshing = false;
        notifyListeners();
      }
    }
  }

  // Load more notifications (pagination)
  Future<void> loadMore(String merchantId) async {
    if (isLoading || !_hasMoreNotifications) return;
    await fetchNotifications(merchantId);
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final success = await _notificationService.markAsRead(notificationId);

      if (success) {
        // Update local state
        _notifications = _notifications.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(isRead: true);
          }
          return notification;
        }).toList();

        notifyListeners();
      }
    } catch (e) {
      dev.log('Error in markAsRead: $e');
      _errorMessage = 'Failed to mark notification as read';
      notifyListeners();
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final success = await _notificationService.markAllAsRead();

      if (success) {
        // Update local state
        _notifications = _notifications.map((notification) {
          return notification.copyWith(isRead: true);
        }).toList();

        notifyListeners();
      }
    } catch (e) {
      dev.log('Error in markAllAsRead: $e');
      _errorMessage = 'Failed to mark all notifications as read';
      notifyListeners();
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final success = await _notificationService.deleteNotification(notificationId);

      if (success) {
        // Update local state
        _notifications = _notifications.where((n) => n.id != notificationId).toList();
        notifyListeners();
      }
    } catch (e) {
      dev.log('Error in deleteNotification: $e');
      _errorMessage = 'Failed to delete notification';
      notifyListeners();
    }
  }
}