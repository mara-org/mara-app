import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import '../utils/logger.dart';
import 'health_data_service.dart';
import 'notification_service.dart';

/// Service to handle native permission requests for camera, microphone, etc.
class NativePermissionService {
  /// Request camera permission and show native system dialog.
  ///
  /// Returns `true` if permission was granted, `false` otherwise.
  Future<bool> requestCameraPermission() async {
    try {
      // Check current status first
      final currentStatus = await Permission.camera.status;

      // If already granted, return true
      if (currentStatus.isGranted) {
        Logger.info(
          'NativePermissionService: Camera permission already granted',
          feature: 'permissions',
          screen: 'native_permission_service',
        );
        return true;
      }

      // Request permission - this will show native system dialog
      final status = await Permission.camera.request();
      final granted = status.isGranted;

      Logger.info(
        'NativePermissionService: Camera permission request result: $granted (status: $status)',
        feature: 'permissions',
        screen: 'native_permission_service',
      );

      return granted;
    } catch (e, stackTrace) {
      Logger.error(
        'NativePermissionService: Error requesting camera permission',
        error: e,
        stackTrace: stackTrace,
        feature: 'permissions',
        screen: 'native_permission_service',
      );
      return false;
    }
  }

  /// Request microphone permission and show native system dialog.
  ///
  /// Returns `true` if permission was granted, `false` otherwise.
  Future<bool> requestMicrophonePermission() async {
    try {
      // Check current status first
      final currentStatus = await Permission.microphone.status;

      // If already granted, return true
      if (currentStatus.isGranted) {
        Logger.info(
          'NativePermissionService: Microphone permission already granted',
          feature: 'permissions',
          screen: 'native_permission_service',
        );
        return true;
      }

      // Request permission - this will show native system dialog
      final status = await Permission.microphone.request();
      final granted = status.isGranted;

      Logger.info(
        'NativePermissionService: Microphone permission request result: $granted (status: $status)',
        feature: 'permissions',
        screen: 'native_permission_service',
      );

      return granted;
    } catch (e, stackTrace) {
      Logger.error(
        'NativePermissionService: Error requesting microphone permission',
        error: e,
        stackTrace: stackTrace,
        feature: 'permissions',
        screen: 'native_permission_service',
      );
      return false;
    }
  }

  /// Request notification permission and show native system dialog.
  ///
  /// Returns `true` if permission was granted, `false` otherwise.
  Future<bool> requestNotificationPermission() async {
    try {
      if (Platform.isIOS) {
        // On iOS, use NotificationService which properly requests via UserNotifications framework
        final notificationService = NotificationService();
        await notificationService.initialize();

        // Request permissions using flutter_local_notifications (shows native iOS dialog)
        final granted = await notificationService.requestPermissionsIfNeeded();

        Logger.info(
          'NativePermissionService: Notification permission request result: $granted',
          feature: 'permissions',
          screen: 'native_permission_service',
        );

        return granted;
      } else {
        // On Android, use permission_handler
        final currentStatus = await Permission.notification.status;

        if (currentStatus.isGranted) {
          Logger.info(
            'NativePermissionService: Notification permission already granted',
            feature: 'permissions',
            screen: 'native_permission_service',
          );
          return true;
        }

        final status = await Permission.notification.request();
        final granted = status.isGranted;

        Logger.info(
          'NativePermissionService: Notification permission request result: $granted',
          feature: 'permissions',
          screen: 'native_permission_service',
        );

        return granted;
      }
    } catch (e, stackTrace) {
      Logger.error(
        'NativePermissionService: Error requesting notification permission',
        error: e,
        stackTrace: stackTrace,
        feature: 'permissions',
        screen: 'native_permission_service',
      );
      return false;
    }
  }

  /// Request health data permission and show native system dialog (HealthKit/Google Fit).
  ///
  /// Returns `true` if permission was granted, `false` otherwise.
  Future<bool> requestHealthDataPermission() async {
    try {
      final healthDataService = HealthDataService();
      final granted = await healthDataService.requestPermissions();

      Logger.info(
        'NativePermissionService: Health data permission request result: $granted',
        feature: 'permissions',
        screen: 'native_permission_service',
      );

      return granted;
    } catch (e, stackTrace) {
      Logger.error(
        'NativePermissionService: Error requesting health data permission',
        error: e,
        stackTrace: stackTrace,
        feature: 'permissions',
        screen: 'native_permission_service',
      );
      return false;
    }
  }

  /// Check if camera permission is granted.
  Future<bool> hasCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      return status.isGranted;
    } catch (e) {
      Logger.error(
        'NativePermissionService: Error checking camera permission',
        error: e,
        feature: 'permissions',
        screen: 'native_permission_service',
      );
      return false;
    }
  }

  /// Check if microphone permission is granted.
  Future<bool> hasMicrophonePermission() async {
    try {
      final status = await Permission.microphone.status;
      return status.isGranted;
    } catch (e) {
      Logger.error(
        'NativePermissionService: Error checking microphone permission',
        error: e,
        feature: 'permissions',
        screen: 'native_permission_service',
      );
      return false;
    }
  }

  /// Check if notification permission is granted.
  Future<bool> hasNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      Logger.error(
        'NativePermissionService: Error checking notification permission',
        error: e,
        feature: 'permissions',
        screen: 'native_permission_service',
      );
      return false;
    }
  }
}
