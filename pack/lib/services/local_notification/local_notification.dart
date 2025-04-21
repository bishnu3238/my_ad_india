import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Advanced Notification Service with multiple features:
/// - Different notification types (OTP, Info, Success, Warning, Error)
/// - Notification actions with buttons
/// - Progress notifications for downloads/uploads
/// - Scheduled notifications with custom repeat intervals
/// - Customizable styles and themes
/// - Grouping and notification channels
/// - Error handling and logging
/// - Cross-platform support (Android, iOS)
class LocalNotificationService {
  // Singleton pattern
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  // Notification plugin
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // Stream controller for notification clicks/actions
  final BehaviorSubject<NotificationResponse> _onNotificationClick = BehaviorSubject<NotificationResponse>();
  Stream<NotificationResponse> get onNotificationClick => _onNotificationClick.stream;

  // Stream controller for ongoing notification progress
  final Map<int, BehaviorSubject<double>> _progressControllers = {};

  // Default notification settings
  final NotificationSettings _defaultSettings = NotificationSettings();

  // Active notifications tracker
  final Map<int, NotificationInfo> _activeNotifications = {};

  // Maximum notification ID to avoid collision
  static const int _maxNotificationId = 2147483647;
  int _lastNotificationId = 0;

  /// Initialize the notification service
  Future<bool> init({
    NotificationSettings? settings,
    Function(NotificationResponse)? onNotificationResponse,
  }) async {
    try {
      // Initialize timezones
      tz.initializeTimeZones();

      // Android initialization settings
      final AndroidInitializationSettings androidSettings = AndroidInitializationSettings(
        settings?.androidSettings?.icon ?? '@mipmap/ic_launcher',
      );

      // iOS initialization settings
      final DarwinInitializationSettings iOSSettings = DarwinInitializationSettings(
        requestAlertPermission: settings?.iOSSettings?.requestAlertPermission ?? true,
        requestBadgePermission: settings?.iOSSettings?.requestBadgePermission ?? true,
        requestSoundPermission: settings?.iOSSettings?.requestSoundPermission ?? true,
        // onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
        notificationCategories: _getNotificationCategories(),
      );

      // Combined initialization settings
      final InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iOSSettings,
      );

      // Initialize the plugin with settings
      final bool result = await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _onNotificationClick.add(response);
          if (onNotificationResponse != null) {
            onNotificationResponse(response);
          }
        },
        onDidReceiveBackgroundNotificationResponse: _notificationResponseCallback,
      ) ?? false;

      // Update default settings if provided
      if (settings != null) {
        _defaultSettings.merge(settings);
      }

      // Create default channels for Android
      if (Platform.isAndroid) {
        await _createDefaultChannels();
      }

      return result;
    } catch (e) {
      _logError('Initialization error', e);
      return false;
    }
  }

  /// Create default notification channels for Android
  Future<void> _createDefaultChannels() async {
    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
      'general_channel',
      'General Notifications',
      description: 'For general app notifications',
      importance: Importance.high,
    ));

    await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
      'otp_channel',
      'OTP Notifications',
      description: 'For one-time password notifications',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    ));

    await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
      'progress_channel',
      'Progress Notifications',
      description: 'For progress updates',
      importance: Importance.low,
    ));

    await androidPlugin.createNotificationChannel(AndroidNotificationChannel(
      'urgent_channel',
      'Urgent Notifications',
      description: 'For high priority notifications',
      importance: Importance.max,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 200, 200, 200]),
    ));
  }

  /// Get iOS notification categories with actions
  List<DarwinNotificationCategory> _getNotificationCategories() {
    // Create notification categories with actions for iOS
    return [
      DarwinNotificationCategory(
        'basic_category',
        actions: [

          DarwinNotificationAction.plain(
            'view',
            'View',
            options: {DarwinNotificationActionOption.foreground},
          ),
          DarwinNotificationAction.plain(
            'dismiss',
            'Dismiss',
            options: {DarwinNotificationActionOption.destructive},
          ),
        ],
      ),
      DarwinNotificationCategory(
        'download_category',
        actions: [
          DarwinNotificationAction.plain(
            'cancel',
            'Cancel',
            options: {DarwinNotificationActionOption.destructive},
          ),
        ],
      ),
    ];
  }

  /// Handle local notification for iOS versions prior to 10
  void _onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) {
    // This is just a legacy method for iOS versions prior to 10
    // Most modern apps don't need to support iOS 9 or below anymore
  }

  /// Static callback to handle notification responses in background
  @pragma('vm:entry-point')
  static void _notificationResponseCallback(NotificationResponse response) {
    // This method needs to be static for background notification handling
    // You can implement custom background logic here if needed
  }

  /// Check and request notification permissions
  Future<PermissionStatus> checkAndRequestPermission() async {
    try {
      // Check Android permission
      if (Platform.isAndroid) {
        final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        if (androidPlugin == null) {
          return PermissionStatus.denied;
        }

        // Check if running on Android 13 or above
        final isAndroid13OrAbove = await _isAndroid13OrAbove();

        // Check if notifications are enabled
        final bool areNotificationsEnabled = await androidPlugin.areNotificationsEnabled() ?? false;

        if (isAndroid13OrAbove && !areNotificationsEnabled) {
          // Request permission on Android 13+
          final bool? granted = await androidPlugin.requestNotificationsPermission();
          return granted == true ? PermissionStatus.granted : PermissionStatus.denied;
        }

        return areNotificationsEnabled ? PermissionStatus.granted : PermissionStatus.denied;
      }
      // Check iOS permission
      else if (Platform.isIOS) {
        final iOSPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        if (iOSPlugin == null) {
          return PermissionStatus.denied;
        }

        // Request permission on iOS
        final bool? granted = await iOSPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

        return granted == true ? PermissionStatus.granted : PermissionStatus.denied;
      }

      return PermissionStatus.unknown;
    } catch (e) {
      _logError('Permission check error', e);
      return PermissionStatus.unknown;
    }
  }

  /// Check if device is running Android 13+
  Future<bool> _isAndroid13OrAbove() async {
    if (!Platform.isAndroid) return false;
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt >= 33;  // Android 13 is API 33
    } catch (e) {
      _logError('Android version check error', e);
      return false;
    }
    // try {
    //   final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    //   if (androidPlugin == null) return false;
    //
    //   // Android 13 is API level 33
    //   final androidInfo = await androidPlugin.getAndroidDeviceInfo();
    //   return (androidInfo?.version.sdkInt ?? 0) >= 33;
    // } catch (e) {
    //   _logError('Android version check error', e);
    //   return false;
    // }
  }

  /// Show a basic notification
  Future<int> show({
    int? id,
    required String title,
    required String body,
    String? payload,
    LocalNotificationType type = LocalNotificationType.info,
    NotificationStyle style = NotificationStyle.basic,
    List<NotificationAction>? actions,
    NotificationSettings? settings,
  }) async {
    try {
      // Generate notification ID if not provided
      final notificationId = id ?? _generateNotificationId();

      // Merge settings with defaults
      final effectiveSettings = _defaultSettings.copy();
      if (settings != null) {
        effectiveSettings.merge(settings);
      }

      // Create notification details based on platform
      final notificationDetails = await _getPlatformNotificationDetails(
        type: type,
        style: style,
        actions: actions,
        settings: effectiveSettings,
      );

      // Show the notification
      await _notificationsPlugin.show(
        notificationId,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      // Track active notification
      _activeNotifications[notificationId] = NotificationInfo(
        id: notificationId,
        title: title,
        body: body,
        type: type,
        timestamp: DateTime.now(),
      );

      return notificationId;
    } catch (e) {
      _logError('Show notification error', e);
      return -1;
    }
  }

  /// Show an OTP notification with specific styling
  Future<int> showOTPNotification({
    int? id,
    required String otp,
    String title = 'Verification Code',
    String? subtitle,
    int expiryMinutes = 10,
    bool useBigTextStyle = true,
  }) async {
    try {
      final notificationId = id ?? _generateNotificationId();

      // Format the OTP message with expiry info
      final String body = subtitle != null
          ? '$subtitle\nYour verification code is: $otp\nValid for $expiryMinutes minutes'
          : 'Your verification code is: $otp\nValid for $expiryMinutes minutes';

      final settings = NotificationSettings()
        ..androidSettings = (AndroidSettings()
          ..channelId = 'otp_channel'
          ..priority = Priority.max
          ..importance = Importance.max
          ..enableVibration = true
          ..vibrationPattern = Int64List.fromList([0, 250, 250, 250])
          ..category = AndroidNotificationCategory.message);

      return await show(
        id: notificationId,
        title: title,
        body: body,
        payload: jsonEncode({'type': 'otp', 'code': otp}),
        type: LocalNotificationType.otp,
        style: useBigTextStyle ? NotificationStyle.bigText : NotificationStyle.basic,
        settings: settings,
      );
    } catch (e) {
      _logError('OTP notification error', e);
      return -1;
    }
  }

  /// Show a progress notification (for downloads, uploads, etc.)
  Future<int> showProgressNotification({
    int? id,
    required String title,
    required String body,
    double initialProgress = 0.0,
    bool indeterminate = false,
    bool ongoing = true,
    Map<String, dynamic>? extras,
  }) async {
    try {
      final notificationId = id ?? _generateNotificationId();

      // Create a progress controller if it doesn't exist
      if (!_progressControllers.containsKey(notificationId)) {
        _progressControllers[notificationId] = BehaviorSubject<double>.seeded(initialProgress);

        // Update notification when progress changes
        _progressControllers[notificationId]!.listen((progress) async {
          if (progress < 0) progress = 0;
          if (progress > 1) progress = 1;

          final int progressPercent = (progress * 100).round();
          final String progressText = indeterminate ? 'In progress...' : '$progressPercent%';

          final androidDetails = AndroidNotificationDetails(
            'progress_channel',
            'Progress Notifications',
            channelDescription: 'For progress updates and downloads',
            importance: Importance.low,
            priority: Priority.low,
            onlyAlertOnce: true,
            showProgress: true,
            maxProgress: 100,
            progress: progressPercent,
            indeterminate: indeterminate,
            ongoing: ongoing,
            autoCancel: !ongoing,
          );

          final iOSDetails = DarwinNotificationDetails(
            presentAlert: false,
            presentBadge: false,
            presentSound: false,
            threadIdentifier: 'progress',
            interruptionLevel: InterruptionLevel.passive,
            categoryIdentifier: 'download_category',
          );

          final notificationDetails = NotificationDetails(
            android: androidDetails,
            iOS: iOSDetails,
          );

          String updatedBody;
          if (progress >= 1.0) {
            updatedBody = 'Download complete';
            ongoing = false;
          } else {
            updatedBody = '$body\n$progressText';
          }

          final Map<String, dynamic> payloadData = {
            'type': 'progress',
            'progress': progress,
            'id': notificationId,
          };

          if (extras != null) {
            payloadData.addAll(extras);
          }

          await _notificationsPlugin.show(
            notificationId,
            title,
            updatedBody,
            notificationDetails,
            payload: jsonEncode(payloadData),
          );

          // If progress is complete, clean up and show completion notification
          if (progress >= 1.0) {
            await updateProgress(id: notificationId, progress: 1.0);
            await Future.delayed(const Duration(seconds: 1));
            await cancelNotification(notificationId);

            // Show completion notification
            await show(
              title: '$title - Complete',
              body: 'The process has finished successfully',
              type: LocalNotificationType.success,
              payload: jsonEncode({'type': 'progress_complete', 'id': notificationId}),
            );

            // Close and remove the progress controller
            await _progressControllers[notificationId]?.close();
            _progressControllers.remove(notificationId);
          }
        });
      }

      // Trigger the initial notification
      _progressControllers[notificationId]!.add(initialProgress);

      return notificationId;
    } catch (e) {
      _logError('Progress notification error', e);
      return -1;
    }
  }

  /// Update progress for an existing progress notification
  Future<bool> updateProgress({required int id, required double progress}) async {
    try {
      if (!_progressControllers.containsKey(id)) {
        return false;
      }

      _progressControllers[id]!.add(progress);
      return true;
    } catch (e) {
      _logError('Update progress error', e);
      return false;
    }
  }

  /// Show a scheduled notification
  Future<int> showScheduledNotification({
    int? id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    LocalNotificationType type = LocalNotificationType.info,
    NotificationStyle style = NotificationStyle.basic,
    RepeatInterval? repeatInterval,
    List<NotificationAction>? actions,
    NotificationSettings? settings,
  }) async {
    try {
      final notificationId = id ?? _generateNotificationId();

      // Merge settings with defaults
      final effectiveSettings = _defaultSettings.copy();
      if (settings != null) {
        effectiveSettings.merge(settings);
      }

      // Create notification details based on platform
      final notificationDetails = await _getPlatformNotificationDetails(
        type: type,
        style: style,
        actions: actions,
        settings: effectiveSettings,
      );

      // Convert to TZ datetime
      final scheduledTzDate = tz.TZDateTime.from(scheduledDate, tz.local);

      // Schedule the notification
      if (repeatInterval != null) {
        await _notificationsPlugin.zonedSchedule(
          notificationId,
          title,
          body,
          scheduledTzDate,
          notificationDetails,
          payload: payload,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          // uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: _getDateTimeComponents(repeatInterval),
        );
      } else {
        await _notificationsPlugin.zonedSchedule(
          notificationId,
          title,
          body,
          scheduledTzDate,
          notificationDetails,
          payload: payload,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }

      return notificationId;
    } catch (e) {
      _logError('Scheduled notification error', e);
      return -1;
    }
  }

  /// Show a notification with custom content (big picture, big text, etc.)
  Future<int> showCustomNotification({
    int? id,
    required String title,
    required String body,
    String? summary,
    String? expandedBody,
    String? largeIcon,
    String? bigPicture,
    List<String>? lines,
    Map<String, String>? buttonActions,
    String? payload,
    LocalNotificationType type = LocalNotificationType.info,
  }) async {
    try {
      final notificationId = id ?? _generateNotificationId();

      // Determine the style based on provided parameters
      NotificationStyle style;
      if (bigPicture != null) {
        style = NotificationStyle.bigPicture;
      } else if (expandedBody != null) {
        style = NotificationStyle.bigText;
      } else if (lines != null && lines.isNotEmpty) {
        style = NotificationStyle.inboxView;
      } else {
        style = NotificationStyle.basic;
      }

      // Create notification actions if button actions provided
      List<NotificationAction>? actions;
      if (buttonActions != null && buttonActions.isNotEmpty) {
        actions = buttonActions.entries.map((entry) {
          return NotificationAction(
            id: entry.key,
            title: entry.value,
          );
        }).toList();
      }

      // Create custom settings for this notification
      final settings = NotificationSettings()
        ..androidSettings = (AndroidSettings()
          ..largeIcon = largeIcon
          ..bigPicture = bigPicture
          ..expandedBody = expandedBody
          ..lines = lines
          ..summary = summary);

      return await show(
        id: notificationId,
        title: title,
        body: body,
        payload: payload,
        type: type,
        style: style,
        actions: actions,
        settings: settings,
      );
    } catch (e) {
      _logError('Custom notification error', e);
      return -1;
    }
  }

  /// Show a group of notifications
  Future<List<int>> showGroupNotifications({
    required String groupKey,
    required String groupTitle,
    required List<NotificationContent> notifications,
    LocalNotificationType type = LocalNotificationType.info,
    bool setAsGroup = true,
  }) async {
    try {
      final List<int> notificationIds = [];

      // Create group summary notification if setAsGroup is true
      if (setAsGroup && notifications.length > 1) {
        final int summaryId = _generateNotificationId();

        final androidDetails = AndroidNotificationDetails(
          type.channelId,
          type.channelName,
          channelDescription: type.channelDescription,
          importance: type.importance,
          priority: type.priority,
          groupKey: groupKey,
          setAsGroupSummary: true,
          styleInformation: InboxStyleInformation(
            notifications.map((n) => n.body).toList(),
            contentTitle: groupTitle,
            summaryText: '${notifications.length} messages',
          ),
        );

        final iOSDetails = DarwinNotificationDetails(
          threadIdentifier: groupKey,
        );

        final notificationDetails = NotificationDetails(
          android: androidDetails,
          iOS: iOSDetails,
        );

        await _notificationsPlugin.show(
          summaryId,
          groupTitle,
          '${notifications.length} new notifications',
          notificationDetails,
        );

        notificationIds.add(summaryId);
      }

      // Show individual notifications
      for (final notification in notifications) {
        final int id = notification.id ?? _generateNotificationId();

        final androidDetails = AndroidNotificationDetails(
          type.channelId,
          type.channelName,
          channelDescription: type.channelDescription,
          importance: type.importance,
          priority: type.priority,
          groupKey: groupKey,
          setAsGroupSummary: false,
        );

        final iOSDetails = DarwinNotificationDetails(
          threadIdentifier: groupKey,
        );

        final notificationDetails = NotificationDetails(
          android: androidDetails,
          iOS: iOSDetails,
        );

        await _notificationsPlugin.show(
          id,
          notification.title,
          notification.body,
          notificationDetails,
          payload: notification.payload,
        );

        notificationIds.add(id);
      }

      return notificationIds;
    } catch (e) {
      _logError('Group notifications error', e);
      return [];
    }
  }

  /// Cancel a specific notification
  Future<bool> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      _activeNotifications.remove(id);

      // Clean up progress controller if exists
      if (_progressControllers.containsKey(id)) {
        await _progressControllers[id]?.close();
        _progressControllers.remove(id);
      }

      return true;
    } catch (e) {
      _logError('Cancel notification error', e);
      return false;
    }
  }

  /// Cancel all notifications
  Future<bool> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      _activeNotifications.clear();

      // Clean up all progress controllers
      for (final controller in _progressControllers.values) {
        await controller.close();
      }
      _progressControllers.clear();

      return true;
    } catch (e) {
      _logError('Cancel all notifications error', e);
      return false;
    }
  }

  /// Get all pending notification requests
  Future<List<PendingNotificationRequest>> getPendingNotificationRequests() async {
    try {
      return await _notificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      _logError('Get pending notifications error', e);
      return [];
    }
  }

  /// Get all active notifications (Android only)
  Future<List<ActiveNotification>> getActiveNotifications() async {
    try {
      if (Platform.isAndroid) {
        final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        return await androidPlugin?.getActiveNotifications() ?? [];
      }
      return [];
    } catch (e) {
      _logError('Get active notifications error', e);
      return [];
    }
  }

  /// Get notification details based on platform and settings
  Future<NotificationDetails> _getPlatformNotificationDetails({
    required LocalNotificationType type,
    required NotificationStyle style,
    List<NotificationAction>? actions,
    required NotificationSettings settings,
  }) async {
    // Android notification details
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      settings.androidSettings?.channelId ?? type.channelId,
      settings.androidSettings?.channelName ?? type.channelName,
      channelDescription: settings.androidSettings?.channelDescription ?? type.channelDescription,
      importance: settings.androidSettings?.importance ?? type.importance,
      priority: settings.androidSettings?.priority ?? type.priority,
      icon: settings.androidSettings?.icon,
      largeIcon: settings.androidSettings?.largeIcon != null ? FilePathAndroidBitmap(settings.androidSettings!.largeIcon!) : null,
      color: settings.androidSettings?.color,
      enableVibration: settings.androidSettings?.enableVibration ?? true,
      vibrationPattern: settings.androidSettings?.vibrationPattern,
      enableLights: settings.androidSettings!.enableLights??false,
      ledColor: settings.androidSettings?.ledColor,
      ledOnMs: settings.androidSettings?.ledOnMs,
      ledOffMs: settings.androidSettings?.ledOffMs,
      ongoing: settings.androidSettings?.ongoing ?? false,
      autoCancel: settings.androidSettings?.autoCancel ?? true,
      timeoutAfter: settings.androidSettings?.timeoutAfter,
      category: settings.androidSettings!.category ,
      fullScreenIntent: settings.androidSettings?.fullScreenIntent ?? false,
      actions: _convertToAndroidNotificationActions(actions),
      styleInformation: await _getAndroidStyleInformation(style, settings.androidSettings),
    );

    // iOS notification details
    DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: settings.iOSSettings?.presentAlert ?? true,
      presentBadge: settings.iOSSettings?.presentBadge ?? true,
      presentSound: settings.iOSSettings?.presentSound ?? true,
      sound: settings.iOSSettings?.sound,
      badgeNumber: settings.iOSSettings?.badgeNumber,
      attachments: await _convertToIOSAttachments(settings.iOSSettings?.attachments),
      subtitle: settings.iOSSettings?.subtitle,
      threadIdentifier: settings.iOSSettings?.threadIdentifier ?? type.name,
      categoryIdentifier: settings.iOSSettings?.categoryIdentifier,
      interruptionLevel: settings.iOSSettings?.interruptionLevel ?? _getInterruptionLevel(type),
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );
  }

  /// Get style information for Android notifications
  Future<StyleInformation> _getAndroidStyleInformation(
      NotificationStyle style,
      AndroidSettings? settings,
      ) async {
    switch (style) {
      case NotificationStyle.basic:
        return const DefaultStyleInformation(true, true);

      case NotificationStyle.bigText:
        return BigTextStyleInformation(
          settings?.expandedBody ?? '',
          contentTitle: settings?.expandedTitle,
          summaryText: settings?.summary,
          htmlFormatBigText: true,
          htmlFormatTitle: true,
        );

      case NotificationStyle.bigPicture:
        if (settings?.bigPicture == null) {
          return const DefaultStyleInformation(true, true);
        }
        return BigPictureStyleInformation(
          FilePathAndroidBitmap(settings!.bigPicture!),
          largeIcon: settings.largeIcon != null ? FilePathAndroidBitmap(settings.largeIcon!) : null,
          contentTitle: settings.expandedTitle,
          summaryText: settings.summary,
          hideExpandedLargeIcon: true,
        );

      case NotificationStyle.inboxView:
        return InboxStyleInformation(
          settings?.lines ?? [],
          contentTitle: settings?.expandedTitle,
          summaryText: settings?.summary,
        );

      case NotificationStyle.mediaStyle:
        return MediaStyleInformation(
          htmlFormatTitle: true,
          htmlFormatContent: true,
        );

      case NotificationStyle.messagingStyle:
        return MessagingStyleInformation(
          const Person(
            name: 'Me',
            important: true,
          ),
          conversationTitle: settings?.expandedTitle,
          groupConversation: true,
          messages: settings?.messages?.map((m) => Message(
            m.text,
            m.timestamp,
            m.person,
          )).toList() ?? [],
        );

      default:
        return const DefaultStyleInformation(true, true);
    }
  }

  /// Convert notification actions to Android notification actions
  List<AndroidNotificationAction>? _convertToAndroidNotificationActions(List<NotificationAction>? actions) {
    if (actions == null || actions.isEmpty) {
      return null;
    }

    return actions.map((action) => AndroidNotificationAction(
      action.id,
      action.title,
      icon: FilePathAndroidBitmap(action.icon!),
      inputs: action.inputs!.map((input) => AndroidNotificationActionInput(
        label: input.label,
        choices: input.choices!,
        allowFreeFormInput: input.allowFreeFormInput,
      )).toList(),
      showsUserInterface: action.launchesApp,
      cancelNotification: action.cancelNotification,
    )).toList();
  }

  /// Convert attachments to iOS notification attachments
  Future<List<DarwinNotificationAttachment>?> _convertToIOSAttachments(List<String>? attachmentPaths) async {
    if (attachmentPaths == null || attachmentPaths.isEmpty) {
      return null;
    }

    return attachmentPaths.map((path) => DarwinNotificationAttachment(
      path,
      identifier: path.split('/').last,
    )).toList();
  }

  /// Get iOS interruption level based on notification type
  InterruptionLevel _getInterruptionLevel(LocalNotificationType type) {
    switch (type) {
      case LocalNotificationType.critical:
        return InterruptionLevel.critical;
      case LocalNotificationType.error:
      case LocalNotificationType.urgent:
        return InterruptionLevel.timeSensitive;
      case LocalNotificationType.otp:
      case LocalNotificationType.success:
        return InterruptionLevel.active;
      case LocalNotificationType.info:
      case LocalNotificationType.warning:
      default:
        return InterruptionLevel.passive;
    }
  }

  /// Get DateTimeComponents for recurring notifications
  DateTimeComponents? _getDateTimeComponents(RepeatInterval interval) {
    switch (interval) {
      case RepeatInterval.everyMinute:
        return DateTimeComponents.time;
      case RepeatInterval.hourly:
        return DateTimeComponents.time;
      case RepeatInterval.daily:
        return DateTimeComponents.time;
      case RepeatInterval.weekly:
        return DateTimeComponents.dayOfWeekAndTime;
      case RepeatInterval.monthly:
        return DateTimeComponents.dayOfMonthAndTime;
      case RepeatInterval.yearly:
        return DateTimeComponents.dateAndTime;
      default:
        return null;
    }
  }

  /// Generate a unique notification ID
  int _generateNotificationId() {
    // Use random number with timestamp to avoid collisions
    _lastNotificationId = (_lastNotificationId + 1) % _maxNotificationId;
    return _lastNotificationId;
  }

  /// Log error for debugging
  void _logError(String message, dynamic error) {
    print('NotificationService Error - $message: $error');
  }

  /// Dispose method to clean up resources
  Future<void> dispose() async {
    for (final controller in _progressControllers.values) {
      await controller.close();
    }
    _progressControllers.clear();
    await _onNotificationClick.close();
  }
}

/// Notification settings class
class NotificationSettings {
  AndroidSettings? androidSettings;
  IOSSettings? iOSSettings;

  NotificationSettings({
    this.androidSettings,
    this.iOSSettings,
  });

  NotificationSettings copy() {
    return NotificationSettings(
      androidSettings: androidSettings != null ? AndroidSettings.from(androidSettings!) : null,
      iOSSettings: iOSSettings != null ? IOSSettings.from(iOSSettings!) : null,
    );
  }

  void merge(NotificationSettings other) {
    if (other.androidSettings != null) {
      androidSettings ??= AndroidSettings();
      androidSettings!.merge(other.androidSettings!);
    }

    if (other.iOSSettings != null) {
      iOSSettings ??= IOSSettings();
      iOSSettings!.merge(other.iOSSettings!);
    }
  }
}

/// Android-specific notification settings
class AndroidSettings {
  String? channelId;
  String? channelName;
  String? channelDescription;
  Importance? importance;
  Priority? priority;
  String? icon;
  String? largeIcon;
  Color? color;
  bool? enableVibration;
  Int64List? vibrationPattern;
  bool? enableLights;
  Color? ledColor;
  int? ledOnMs;
  int? ledOffMs;
  bool? ongoing;
  bool? autoCancel;
  int? timeoutAfter;
  AndroidNotificationCategory? category;
  bool? fullScreenIntent;
  String? expandedTitle;
  String? expandedBody;
  String? bigPicture;
  String? summary;
  List<String>? lines;
  List<MessageData>? messages;

  AndroidSettings({
    this.channelId,
    this.channelName,
    this.channelDescription,
    this.importance,
    this.priority,
    this.icon,
    this.largeIcon,
    this.color,
    this.enableVibration,
    this.vibrationPattern,
    this.enableLights,
    this.ledColor,
    this.ledOnMs,
    this.ledOffMs,
    this.ongoing,
    this.autoCancel,
    this.timeoutAfter,
    this.category,
    this.fullScreenIntent,
    this.expandedTitle,
    this.expandedBody,
    this.bigPicture,
    this.summary,
    this.lines,
    this.messages,
  });

  static AndroidSettings from(AndroidSettings settings) {
    return AndroidSettings(
      channelId: settings.channelId,
      channelName: settings.channelName,
      channelDescription: settings.channelDescription,
      importance: settings.importance,
      priority: settings.priority,
      icon: settings.icon,
      largeIcon: settings.largeIcon,
      color: settings.color,
      enableVibration: settings.enableVibration,
      vibrationPattern: settings.vibrationPattern,
      enableLights: settings.enableLights,
      ledColor: settings.ledColor,
      ledOnMs: settings.ledOnMs,
      ledOffMs: settings.ledOffMs,
      ongoing: settings.ongoing,
      autoCancel: settings.autoCancel,
      timeoutAfter: settings.timeoutAfter,
      category: settings.category,
      fullScreenIntent: settings.fullScreenIntent,
      expandedTitle: settings.expandedTitle,
      expandedBody: settings.expandedBody,
      bigPicture: settings.bigPicture,
      summary: settings.summary,
      lines: settings.lines != null ? List<String>.from(settings.lines!) : null,
      /// TODO: this is old original code, next line is updated code.
      // messages: settings.messages != null ? settings.messages!.map((m) => MessageData.from(m)).toList() : null,
      messages: settings.messages?.map((m) => MessageData.from(m)).toList(),
    );
  }

  void merge(AndroidSettings other) {
    channelId = other.channelId ?? channelId;
    channelName = other.channelName ?? channelName;
    channelDescription = other.channelDescription ?? channelDescription;
    importance = other.importance ?? importance;
    priority = other.priority ?? priority;
    icon = other.icon ?? icon;
    largeIcon = other.largeIcon ?? largeIcon;
    color = other.color ?? color;
    enableVibration = other.enableVibration ?? enableVibration;
    vibrationPattern = other.vibrationPattern ?? vibrationPattern;
    enableLights = other.enableLights ?? enableLights;
    ledColor = other.ledColor ?? ledColor;
    ledOnMs = other.ledOnMs ?? ledOnMs;
    ledOffMs = other.ledOffMs ?? ledOffMs;
    ongoing = other.ongoing ?? ongoing;
    autoCancel = other.autoCancel ?? autoCancel;
    timeoutAfter = other.timeoutAfter ?? timeoutAfter;
    category = other.category ?? category;
    fullScreenIntent = other.fullScreenIntent ?? fullScreenIntent;
    expandedTitle = other.expandedTitle ?? expandedTitle;
    expandedBody = other.expandedBody ?? expandedBody;
    bigPicture = other.bigPicture ?? bigPicture;
    summary = other.summary ?? summary;
    lines = other.lines ?? lines;
    messages = other.messages ?? messages;
  }
}

/// iOS-specific notification settings
class IOSSettings {
  bool? requestAlertPermission;
  bool? requestBadgePermission;
  bool? requestSoundPermission;
  bool? presentAlert;
  bool? presentBadge;
  bool? presentSound;
  String? sound;
  int? badgeNumber;
  List<String>? attachments;
  String? subtitle;
  String? threadIdentifier;
  String? categoryIdentifier;
  InterruptionLevel? interruptionLevel;

  IOSSettings({
    this.requestAlertPermission,
    this.requestBadgePermission,
    this.requestSoundPermission,
    this.presentAlert,
    this.presentBadge,
    this.presentSound,
    this.sound,
    this.badgeNumber,
    this.attachments,
    this.subtitle,
    this.threadIdentifier,
    this.categoryIdentifier,
    this.interruptionLevel,
  });

  static IOSSettings from(IOSSettings settings) {
    return IOSSettings(
      requestAlertPermission: settings.requestAlertPermission,
      requestBadgePermission: settings.requestBadgePermission,
      requestSoundPermission: settings.requestSoundPermission,
      presentAlert: settings.presentAlert,
      presentBadge: settings.presentBadge,
      presentSound: settings.presentSound,
      sound: settings.sound,
      badgeNumber: settings.badgeNumber,
      attachments: settings.attachments != null ? List<String>.from(settings.attachments!) : null,
      subtitle: settings.subtitle,
      threadIdentifier: settings.threadIdentifier,
      categoryIdentifier: settings.categoryIdentifier,
      interruptionLevel: settings.interruptionLevel,
    );
  }

  void merge(IOSSettings other) {
    requestAlertPermission = other.requestAlertPermission ?? requestAlertPermission;
    requestBadgePermission = other.requestBadgePermission ?? requestBadgePermission;
    requestSoundPermission = other.requestSoundPermission ?? requestSoundPermission;
    presentAlert = other.presentAlert ?? presentAlert;
    presentBadge = other.presentBadge ?? presentBadge;
    presentSound = other.presentSound ?? presentSound;
    sound = other.sound ?? sound;
    badgeNumber = other.badgeNumber ?? badgeNumber;
    attachments = other.attachments ?? attachments;
    subtitle = other.subtitle ?? subtitle;
    threadIdentifier = other.threadIdentifier ?? threadIdentifier;
    categoryIdentifier = other.categoryIdentifier ?? categoryIdentifier;
    interruptionLevel = other.interruptionLevel ?? interruptionLevel;
  }
}

/// Notification type enum
enum LocalNotificationType {
  info,
  success,
  warning,
  error,
  otp,
  urgent,
  critical;

  String get channelId {
    switch (this) {
      case LocalNotificationType.info:
        return 'general_channel';
      case LocalNotificationType.success:
        return 'general_channel';
      case LocalNotificationType.warning:
        return 'general_channel';
      case LocalNotificationType.error:
        return 'urgent_channel';
      case LocalNotificationType.otp:
        return 'otp_channel';
      case LocalNotificationType.urgent:
        return 'urgent_channel';
      case LocalNotificationType.critical:
        return 'urgent_channel';
    }
  }

  String get channelName {
    switch (this) {
      case LocalNotificationType.info:
      case LocalNotificationType.success:
      case LocalNotificationType.warning:
        return 'General Notifications';
      case LocalNotificationType.error:
      case LocalNotificationType.urgent:
      case LocalNotificationType.critical:
        return 'Urgent Notifications';
      case LocalNotificationType.otp:
        return 'OTP Notifications';
    }
  }

  String get channelDescription {
    switch (this) {
      case LocalNotificationType.info:
      case LocalNotificationType.success:
      case LocalNotificationType.warning:
        return 'For general app notifications';
      case LocalNotificationType.error:
      case LocalNotificationType.urgent:
      case LocalNotificationType.critical:
        return 'For high priority notifications';
      case LocalNotificationType.otp:
        return 'For one-time password notifications';
    }
  }

  Importance get importance {
    switch (this) {
      case LocalNotificationType.info:
      case LocalNotificationType.success:
        return Importance.defaultImportance;
      case LocalNotificationType.warning:
        return Importance.high;
      case LocalNotificationType.error:
      case LocalNotificationType.urgent:
      case LocalNotificationType.critical:
      case LocalNotificationType.otp:
        return Importance.max;
    }
  }

  Priority get priority {
    switch (this) {
      case LocalNotificationType.info:
      case LocalNotificationType.success:
        return Priority.defaultPriority;
      case LocalNotificationType.warning:
        return Priority.high;
      case LocalNotificationType.error:
      case LocalNotificationType.urgent:
      case LocalNotificationType.critical:
      case LocalNotificationType.otp:
        return Priority.max;
    }
  }
}

/// Notification style enum
enum NotificationStyle {
  basic,
  bigText,
  bigPicture,
  inboxView,
  mediaStyle,
  messagingStyle,
}

/// Repeat interval for scheduled notifications
enum RepeatInterval {
  everyMinute,
  hourly,
  daily,
  weekly,
  monthly,
  yearly,
}

/// Permission status enum
enum PermissionStatus {
  granted,
  denied,
  unknown,
}

/// Notification action class
class NotificationAction {
  final String id;
  final String title;
  final String? icon;
  final List<NotificationActionInput>? inputs;
  final bool launchesApp;
  final bool cancelNotification;

  NotificationAction({
    required this.id,
    required this.title,
    this.icon,
    this.inputs,
    this.launchesApp = true,
    this.cancelNotification = true,
  });
}

/// Input for notification actions
class NotificationActionInput {
  final String label;
  final List<String>? choices;
  final bool allowFreeFormInput;

  NotificationActionInput({
    required this.label,
    this.choices,
    this.allowFreeFormInput = true,
  });
}

/// Message data for messaging style notifications
class MessageData {
  final String text;
  final DateTime timestamp;
  final Person person;

  MessageData({
    required this.text,
    required this.timestamp,
    required this.person,
  });

  static MessageData from(MessageData data) {
    return MessageData(
      text: data.text,
      timestamp: data.timestamp,
      person: data.person,
    );
  }
}

/// Notification content for group notifications
class NotificationContent {
  final int? id;
  final String title;
  final String body;
  final String? payload;

  NotificationContent({
    this.id,
    required this.title,
    required this.body,
    this.payload,
  });
}

/// Notification info class to track active notifications
class NotificationInfo {
  final int id;
  final String title;
  final String body;
  final LocalNotificationType type;
  final DateTime timestamp;

  NotificationInfo({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
  });
}