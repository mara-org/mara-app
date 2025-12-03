import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Crash reporter for Mara app
/// 
/// Currently logs errors to console. In the future, this should:
/// - Send crashes to a backend endpoint
/// - Backend will forward critical crashes to Discord webhook (DISCORD_WEBHOOK_ALERTS)
/// - Include device info, stack trace, and app version
class CrashReporter {
  /// Initialize crash handling for the app
  /// 
  /// This should be called before runApp() in main.dart
  static void initialize() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError(
        error: details.exception,
        stackTrace: details.stack,
        context: 'Flutter framework error',
      );
    };

    // Handle async errors outside Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError(
        error: error,
        stackTrace: stack,
        context: 'Platform dispatcher error',
      );
      return true;
    };
  }

  /// Run app with crash handling zone
  /// 
  /// Use this instead of runApp() to ensure all errors are caught
  static void runAppWithCrashHandling(Widget app) {
    runZonedGuarded<Future<void>>(
      () async {
        runApp(app);
      },
      (error, stack) {
        _logError(
          error: error,
          stackTrace: stack,
          context: 'Uncaught error in zone',
        );
      },
    );
  }

  /// Log error to console (and eventually to backend)
  static void _logError({
    required Object error,
    StackTrace? stackTrace,
    required String context,
  }) {
    // TODO: In the future, send this to backend endpoint
    // Backend should forward critical crashes to DISCORD_WEBHOOK_ALERTS
    // Include: device info, app version, error details, stack trace
    
    if (kDebugMode) {
      debugPrint('=== CRASH REPORT ===');
      debugPrint('Context: $context');
      debugPrint('Error: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
      debugPrint('===================');
    }

    // In production, log to console for now
    // TODO: Implement backend crash reporting
    // Example future implementation:
    // await _sendToBackend({
    //   'error': error.toString(),
    //   'stackTrace': stackTrace?.toString(),
    //   'context': context,
    //   'deviceInfo': await _getDeviceInfo(),
    //   'appVersion': await _getAppVersion(),
    // });
  }
}

