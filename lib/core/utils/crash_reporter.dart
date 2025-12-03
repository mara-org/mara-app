import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// TODO: Uncomment when backend is available
// import 'package:http/http.dart' as http;
// import 'dart:convert';
import 'platform_utils.dart';
import '../../shared/system/system_info_service.dart';

/// Crash reporter for Mara app
///
/// Currently logs errors to console. When backend is available, this will:
/// - Send crashes to backend endpoint (configured via environment variable)
/// - Backend forwards critical crashes to Discord webhook (DISCORD_WEBHOOK_ALERTS or DISCORD_WEBHOOK_CRASHES)
/// - Include device info, stack trace, and app version
class CrashReporter {
  // TODO: Set this via environment variable or config when backend is available
  static const String? _backendCrashEndpoint = null; // e.g., 'https://api.mara.app/crashes'
  
  static final SystemInfoService _systemInfo = SystemInfoService();
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
    // Always log to console for debugging
    if (kDebugMode) {
      debugPrint('=== CRASH REPORT ===');
      debugPrint('Context: $context');
      debugPrint('Error: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
      debugPrint('===================');
    }

    // Send to backend if endpoint is configured
    if (_backendCrashEndpoint != null) {
      _sendToBackend(
        error: error,
        stackTrace: stackTrace,
        context: context,
      ).catchError((e) {
        // Silently fail - don't crash the app if crash reporting fails
        debugPrint('Failed to send crash report to backend: $e');
      });
    }
  }

  /// Send crash report to backend endpoint
  /// 
  /// Backend should:
  /// 1. Store crash report in database
  /// 2. Forward critical crashes to DISCORD_WEBHOOK_ALERTS or DISCORD_WEBHOOK_CRASHES
  /// 3. Aggregate and deduplicate crashes
  static Future<void> _sendToBackend({
    required Object error,
    StackTrace? stackTrace,
    required String context,
  }) async {
    if (_backendCrashEndpoint == null) {
      return; // Backend not configured yet
    }

    try {
      // Collect device and app info
      final deviceInfo = await _systemInfo.getDeviceInfo();
      final appVersion = await _systemInfo.getAppVersion();
      final platform = PlatformUtils.getPlatformName();

      // Build crash report payload
      final crashReport = {
        'error': error.toString(),
        'stackTrace': stackTrace?.toString(),
        'context': context,
        'deviceInfo': deviceInfo,
        'appVersion': appVersion,
        'platform': platform,
        'timestamp': DateTime.now().toIso8601String(),
        'severity': _determineSeverity(error, context),
      };

      // TODO: Uncomment when http package is added and backend is available
      // final response = await http.post(
      //   Uri.parse(_backendCrashEndpoint!),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode(crashReport),
      // ).timeout(const Duration(seconds: 5));
      //
      // if (response.statusCode != 200 && response.statusCode != 201) {
      //   debugPrint('Backend returned error: ${response.statusCode}');
      // }

      // For now, just log what would be sent
      if (kDebugMode) {
        debugPrint('Would send crash report to backend:');
        debugPrint('Endpoint: $_backendCrashEndpoint');
        debugPrint('Payload: $crashReport');
      }
    } catch (e) {
      // Silently fail - don't crash the app if crash reporting fails
      debugPrint('Error sending crash report: $e');
    }
  }

  /// Determine crash severity based on error type and context
  static String _determineSeverity(Object error, String context) {
    final errorString = error.toString().toLowerCase();
    
    // Critical errors
    if (errorString.contains('outofmemory') ||
        errorString.contains('nullpointer') ||
        errorString.contains('assertion') ||
        context.contains('framework')) {
      return 'critical';
    }
    
    // High severity
    if (errorString.contains('network') ||
        errorString.contains('timeout') ||
        errorString.contains('connection')) {
      return 'high';
    }
    
    // Default to medium
    return 'medium';
  }
}
