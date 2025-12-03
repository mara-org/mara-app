import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Observability imports - Sentry and Firebase Crashlytics
// These are optional dependencies - app will work without them if not configured
// Configure via environment variables or runtime config
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Crash reporter for Mara app
///
/// Integrates with Sentry and/or Firebase Crashlytics for crash reporting.
/// In debug mode: logs to console
/// In release mode: sends to Sentry/Firebase (if configured)
///
/// Configuration:
/// - Set SENTRY_DSN environment variable or configure at runtime
/// - Firebase is initialized separately via Firebase.initializeApp()
///
/// Note: No backend endpoint needed - crashes go directly to SaaS observability tools
class CrashReporter {
  static bool _initialized = false;
  static String? _sentryDsn;
  static bool _useFirebase = false;

  /// Initialize crash reporting
  ///
  /// [sentryDsn] - Sentry DSN (optional, can be set via environment variable)
  /// [useFirebase] - Whether to use Firebase Crashlytics (requires Firebase.initializeApp() first)
  static Future<void> init({
    String? sentryDsn,
    bool useFirebase = false,
  }) async {
    if (_initialized) return;

    _sentryDsn = sentryDsn ?? const String.fromEnvironment('SENTRY_DSN');
    _useFirebase = useFirebase;

    _initialized = true;

    if (kDebugMode) {
      debugPrint('CrashReporter initialized');
      if (_sentryDsn != null && _sentryDsn!.isNotEmpty) {
        debugPrint('Sentry enabled (DSN configured)');
      }
      if (_useFirebase) {
        debugPrint('Firebase Crashlytics enabled');
      }
    }
  }

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

  /// Record an error
  ///
  /// Public method to record errors manually
  static Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? context,
  }) async {
    await _logError(
      error: error,
      stackTrace: stackTrace,
      context: context ?? 'Manual error report',
    );
  }

  /// Log error to console and send to observability services
  static Future<void> _logError({
    required Object error,
    StackTrace? stackTrace,
    required String context,
  }) async {
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

    // In release mode, send to observability services
    if (!kDebugMode) {
      // Send to Sentry if configured
      if (_sentryDsn != null && _sentryDsn!.isNotEmpty) {
        try {
          await Sentry.captureException(
            error,
            stackTrace: stackTrace,
            hint: Hint.withMap({'context': context}),
          );
        } catch (e) {
          // Silently fail - don't crash the app if crash reporting fails
          debugPrint('Failed to send to Sentry: $e');
        }
      }

      // Send to Firebase Crashlytics if enabled
      if (_useFirebase) {
        try {
          await FirebaseCrashlytics.instance.recordError(
            error,
            stackTrace,
            reason: context,
            fatal: _determineSeverity(error, context) == 'critical',
          );
        } catch (e) {
          // Silently fail
          debugPrint('Failed to send to Firebase: $e');
        }
      }
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
