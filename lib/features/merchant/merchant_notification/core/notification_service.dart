// notification_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:pack/services/snack_bar_service/notify_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_model.dart';

class NotificationService {
  static const String _baseUrl = 'https://api.example.com/notifications';
  static const String _notificationCacheKey = 'cached_notifications';

  // Mock data for demo purposes
  final List<NotificationModel> _mockNotifications = [
    NotificationModel(
      id: '1',
      title: 'New Inquiry Received',
      message: 'You have received a new inquiry for your Car Wash service.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      type: MerchantNotificationType.info,
      actionLink: '/inquiries/details/12345',
    ),
    NotificationModel(
      id: '2',
      title: 'Payment Successful',
      message: 'Your subscription has been renewed successfully.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: MerchantNotificationType.success,
    ),
    NotificationModel(
      id: '3',
      title: 'Service Update Required',
      message: 'Please update your service description to comply with our new guidelines.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: MerchantNotificationType.warning,
      actionLink: '/services/edit/67890',
    ),
    NotificationModel(
      id: '4',
      title: 'Account Verification',
      message: 'Your account verification is pending. Please complete the verification process.',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      type: MerchantNotificationType.accountUpdate,
      actionLink: '/account/verify',
    ),
    NotificationModel(
      id: '5',
      title: 'Special Offer',
      message: 'Upgrade to Premium plan now and get 20% off for the first 3 months!',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      type: MerchantNotificationType.promotion,
      actionLink: '/subscription/upgrade',
      additionalData: {'discount': 20, 'months': 3},
    ),
  ];

  // Get notifications from API
  Future<List<NotificationModel>> fetchNotifications({
    required String merchantId,
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    try {
      // In a real app, we would make an API request here
      // For demo purposes, we'll return mock data with a simulated delay
      if (!forceRefresh) {
        // Try to get from cache first if not forcing refresh
        final cachedNotifications = await _getCachedNotifications();
        if (cachedNotifications.isNotEmpty) {
          return cachedNotifications;
        }
      }

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Return mock data
      await _cacheNotifications(_mockNotifications);
      return _mockNotifications;

      // In a real implementation, we would do something like:
      // final response = await http.get(
      //   Uri.parse('$_baseUrl?merchant_id=$merchantId&page=$page&limit=$limit'),
      //   headers: {'Authorization': 'Bearer $token'},
      // );
      //
      // if (response.statusCode == 200) {
      //   final List<dynamic> data = json.decode(response.body)['data'];
      //   final notifications = data.map((item) => NotificationModel.fromJson(item)).toList();
      //   await _cacheNotifications(notifications);
      //   return notifications;
      // } else {
      //   throw Exception('Failed to load notifications');
      // }
    } catch (e) {
      dev.log('Error fetching notifications: $e');
      // If we can't get from network, try to get from cache as fallback
      final cachedNotifications = await _getCachedNotifications();
      if (cachedNotifications.isNotEmpty) {
        return cachedNotifications;
      }
      rethrow;
    }
  }

  // Mark a notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Update local cache
      final notifications = await _getCachedNotifications();
      final updatedNotifications = notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();

      await _cacheNotifications(updatedNotifications);
      return true;

      // In a real implementation, we would do something like:
      // final response = await http.patch(
      //   Uri.parse('$_baseUrl/$notificationId/read'),
      //   headers: {'Authorization': 'Bearer $token'},
      // );
      // return response.statusCode == 200;
    } catch (e) {
      dev.log('Error marking notification as read: $e');
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Update local cache
      final notifications = await _getCachedNotifications();
      final updatedNotifications = notifications.map((notification) {
        return notification.copyWith(isRead: true);
      }).toList();

      await _cacheNotifications(updatedNotifications);
      return true;

      // In a real implementation, we would do something like:
      // final response = await http.patch(
      //   Uri.parse('$_baseUrl/mark-all-read'),
      //   headers: {'Authorization': 'Bearer $token'},
      // );
      // return response.statusCode == 200;
    } catch (e) {
      dev.log('Error marking all notifications as read: $e');
      return false;
    }
  }

  // Delete a notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Update local cache
      final notifications = await _getCachedNotifications();
      final updatedNotifications = notifications.where((n) => n.id != notificationId).toList();

      await _cacheNotifications(updatedNotifications);
      return true;

      // In a real implementation, we would do something like:
      // final response = await http.delete(
      //   Uri.parse('$_baseUrl/$notificationId'),
      //   headers: {'Authorization': 'Bearer $token'},
      // );
      // return response.statusCode == 200;
    } catch (e) {
      dev.log('Error deleting notification: $e');
      return false;
    }
  }

  // Helper methods for caching
  Future<void> _cacheNotifications(List<NotificationModel> notifications) async {
    // This is a simplified implementation. In a real app, you would use a more
    // sophisticated caching mechanism, possibly with expiration times.
    try {
      final prefs = await SharedPreferences.getInstance();

      // For this demo, we'll just store the notification IDs and read status
      // In a real app, you might want to store more data
      final Map<String, dynamic> cache = {};
      for (var notification in _mockNotifications) {
        cache[notification.id] = notification.isRead;
      }

      await prefs.setString(_notificationCacheKey, json.encode(cache));
    } catch (e) {
      dev.log('Error caching notifications: $e');
    }
  }

  Future<List<NotificationModel>> _getCachedNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_notificationCacheKey);

      if (cachedData == null) {
        return [];
      }

      final Map<String, dynamic> cache = json.decode(cachedData);

      // Merge cache data with mock data for demo purposes
      return _mockNotifications.map((notification) {
        final isRead = cache[notification.id] ?? false;
        return notification.copyWith(isRead: isRead);
      }).toList();
    } catch (e) {
      dev.log('Error getting cached notifications: $e');
      return [];
    }
  }

  // Get unread notifications count
  Future<int> getUnreadCount() async {
    final notifications = await _getCachedNotifications();
    return notifications.where((n) => !n.isRead).length;
  }
}