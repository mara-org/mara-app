import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../utils/logger.dart';

/// Abstract interface for notification service.
abstract class INotificationService {
  /// Initialize the notification service.
  Future<bool> initialize();

  /// Request notification permissions if needed.
  Future<bool> requestPermissionsIfNeeded();

  /// Schedule a daily reminder at the specified time.
  ///
  /// [id] - Unique notification ID
  /// [title] - Notification title
  /// [body] - Notification body
  /// [hour] - Hour of day (0-23)
  /// [minute] - Minute (0-59)
  Future<bool> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  });

  /// Cancel a scheduled reminder.
  Future<bool> cancelReminder(int id);

  /// Cancel all scheduled reminders.
  Future<bool> cancelAllReminders();
}

/// Implementation of [INotificationService] using flutter_local_notifications.
class NotificationService implements INotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  @override
  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      // Initialize timezone data
      tzdata.initializeTimeZones();

      // Android initialization settings
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Initialization settings
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize plugin
      final initialized = await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      if (initialized == true) {
        _initialized = true;
        Logger.info(
          'NotificationService: Initialized successfully',
          feature: 'notifications',
          screen: 'notification_service',
        );
      }

      return initialized ?? false;
    } catch (e, stackTrace) {
      Logger.error(
        'NotificationService: Error initializing',
        error: e,
        stackTrace: stackTrace,
        feature: 'notifications',
        screen: 'notification_service',
      );
      return false;
    }
  }

  @override
  Future<bool> requestPermissionsIfNeeded() async {
    try {
      if (!_initialized) {
        await initialize();
      }

      // Request permissions for iOS - this will show native system dialog
      final iosImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        Logger.info(
          'NotificationService: iOS permission request result: $granted',
          feature: 'notifications',
          screen: 'notification_service',
        );
        return granted ?? false;
      }

      // Request permissions for Android
      final android =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        await android.requestNotificationsPermission();
      }

      return true;
    } catch (e, stackTrace) {
      Logger.error(
        'NotificationService: Error requesting permissions',
        error: e,
        stackTrace: stackTrace,
        feature: 'notifications',
        screen: 'notification_service',
      );
      return false;
    }
  }

  @override
  Future<bool> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    try {
      if (!_initialized) {
        await initialize();
      }

      // Schedule notification to repeat daily
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'health_reminders',
            'Health Reminders',
            channelDescription: 'Daily reminders for health goals',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      Logger.info(
        'NotificationService: Scheduled daily reminder at $hour:$minute',
        feature: 'notifications',
        screen: 'notification_service',
      );

      return true;
    } catch (e, stackTrace) {
      Logger.error(
        'NotificationService: Error scheduling reminder',
        error: e,
        stackTrace: stackTrace,
        feature: 'notifications',
        screen: 'notification_service',
      );
      return false;
    }
  }

  @override
  Future<bool> cancelReminder(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      return true;
    } catch (e, stackTrace) {
      Logger.error(
        'NotificationService: Error canceling reminder',
        error: e,
        stackTrace: stackTrace,
        feature: 'notifications',
        screen: 'notification_service',
      );
      return false;
    }
  }

  @override
  Future<bool> cancelAllReminders() async {
    try {
      await _notificationsPlugin.cancelAll();
      return true;
    } catch (e, stackTrace) {
      Logger.error(
        'NotificationService: Error canceling all reminders',
        error: e,
        stackTrace: stackTrace,
        feature: 'notifications',
        screen: 'notification_service',
      );
      return false;
    }
  }

  /// Calculate the next occurrence of the specified time.
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Handle notification tap.
  void _onNotificationTap(NotificationResponse response) {
    Logger.info(
      'NotificationService: Notification tapped: ${response.id}',
      feature: 'notifications',
      screen: 'notification_service',
    );
    // Handle notification tap (e.g., navigate to specific screen)
  }
}
