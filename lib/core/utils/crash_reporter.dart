import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Observability imports - Sentry and Firebase Crashlytics
// These are optional dependencies - app will work without them if not configured
// Configure via environment variables or runtime config
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

  // Context tags for error reporting
  static String? _environment;
  static String? _appVersion;
  static String? _buildNumber;
  static String? _currentScreen;
  static String? _currentFeature;

  /// Initialize crash reporting
  ///
  /// [sentryDsn] - Sentry DSN (optional, can be set via environment variable)
  /// [useFirebase] - Whether to use Firebase Crashlytics (requires Firebase.initializeApp() first)
  /// [environment] - Environment name (e.g., 'production', 'staging', 'development')
  static Future<void> init({
    String? sentryDsn,
    bool useFirebase = false,
    String? environment,
  }) async {
    if (_initialized) return;

    _sentryDsn = sentryDsn ?? const String.fromEnvironment('SENTRY_DSN');
    _useFirebase = useFirebase;
    _environment = environment ?? (kDebugMode ? 'development' : 'production');

    // Get app version and build number
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get package info: $e');
      }
    }

    _initialized = true;

    // Set default tags in Sentry
    if (_sentryDsn != null && _sentryDsn!.isNotEmpty) {
      try {
        Sentry.configureScope((scope) {
          scope.setTag('environment', _environment ?? 'unknown');
          if (_appVersion != null) {
            scope.setTag('app_version', _appVersion!);
          }
          if (_buildNumber != null) {
            scope.setTag('build_number', _buildNumber!);
          }
        });
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Failed to set Sentry tags: $e');
        }
      }
    }

    // Set default tags in Firebase Crashlytics
    if (_useFirebase) {
      try {
        if (_environment != null) {
          FirebaseCrashlytics.instance
              .setCustomKey('environment', _environment!);
        }
        if (_appVersion != null) {
          FirebaseCrashlytics.instance
              .setCustomKey('app_version', _appVersion!);
        }
        if (_buildNumber != null) {
          FirebaseCrashlytics.instance
              .setCustomKey('build_number', _buildNumber!);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Failed to set Firebase tags: $e');
        }
      }
    }

    if (kDebugMode) {
      debugPrint('CrashReporter initialized');
      debugPrint('Environment: $_environment');
      if (_appVersion != null) {
        debugPrint('App Version: $_appVersion (Build: $_buildNumber)');
      }
      if (_sentryDsn != null && _sentryDsn!.isNotEmpty) {
        debugPrint('Sentry enabled (DSN configured)');
      }
      if (_useFirebase) {
        debugPrint('Firebase Crashlytics enabled');
      }
    }
  }

  /// Set current screen context
  ///
  /// Call this when navigating to a new screen
  static void setScreen(String screen) {
    _currentScreen = screen;

    if (_sentryDsn != null && _sentryDsn!.isNotEmpty) {
      try {
        Sentry.configureScope((scope) {
          scope.setTag('screen', screen);
        });
      } catch (e) {
        // Silently fail
      }
    }

    if (_useFirebase) {
      try {
        FirebaseCrashlytics.instance.setCustomKey('screen', screen);
      } catch (e) {
        // Silently fail
      }
    }
  }

  /// Set current feature context
  ///
  /// Call this when entering a feature flow
  static void setFeature(String feature) {
    _currentFeature = feature;

    if (_sentryDsn != null && _sentryDsn!.isNotEmpty) {
      try {
        Sentry.configureScope((scope) {
          scope.setTag('feature', feature);
        });
      } catch (e) {
        // Silently fail
      }
    }

    if (_useFirebase) {
      try {
        FirebaseCrashlytics.instance.setCustomKey('feature', feature);
      } catch (e) {
        // Silently fail
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
        screen: _currentScreen,
        feature: _currentFeature,
      );
    };

    // Handle async errors outside Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError(
        error: error,
        stackTrace: stack,
        context: 'Platform dispatcher error',
        screen: _currentScreen,
        feature: _currentFeature,
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
          screen: _currentScreen,
          feature: _currentFeature,
        );
      },
    );
  }

  /// Record an error
  ///
  /// Public method to record errors manually
  ///
  /// [error] - The error object
  /// [stackTrace] - Stack trace (optional)
  /// [context] - Context description
  /// [screen] - Current screen (optional, defaults to _currentScreen)
  /// [feature] - Current feature (optional, defaults to _currentFeature)
  static Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? context,
    String? screen,
    String? feature,
  }) async {
    await _logError(
      error: error,
      stackTrace: stackTrace,
      context: context ?? 'Manual error report',
      screen: screen ?? _currentScreen,
      feature: feature ?? _currentFeature,
    );
  }

  /// Log error to console and send to observability services
  static Future<void> _logError({
    required Object error,
    StackTrace? stackTrace,
    required String context,
    String? screen,
    String? feature,
  }) async {
    // Determine error type
    final errorType = _determineErrorType(error, context);

    // Always log to console for debugging
    if (kDebugMode) {
      debugPrint('=== CRASH REPORT ===');
      debugPrint('Context: $context');
      debugPrint('Error: $error');
      debugPrint('Error Type: $errorType');
      if (screen != null) debugPrint('Screen: $screen');
      if (feature != null) debugPrint('Feature: $feature');
      if (_environment != null) debugPrint('Environment: $_environment');
      if (_appVersion != null)
        debugPrint('Version: $_appVersion (Build: $_buildNumber)');
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
            withScope: (scope) {
              // Set tags
              scope.setTag('error_type', errorType);
              if (screen != null) scope.setTag('screen', screen);
              if (feature != null) scope.setTag('feature', feature);
              if (_environment != null)
                scope.setTag('environment', _environment!);
              if (_appVersion != null)
                scope.setTag('app_version', _appVersion!);
              if (_buildNumber != null)
                scope.setTag('build_number', _buildNumber!);

              // Set context
              scope.setContexts('error_details', {
                'context': context,
                'error_type': errorType,
                if (screen != null) 'screen': screen,
                if (feature != null) 'feature': feature,
              });
            },
          );
        } catch (e) {
          // Silently fail - don't crash the app if crash reporting fails
          debugPrint('Failed to send to Sentry: $e');
        }
      }

      // Send to Firebase Crashlytics if enabled
      if (_useFirebase) {
        try {
          // Set custom keys before recording
          FirebaseCrashlytics.instance.setCustomKey('error_type', errorType);
          if (screen != null) {
            FirebaseCrashlytics.instance.setCustomKey('screen', screen);
          }
          if (feature != null) {
            FirebaseCrashlytics.instance.setCustomKey('feature', feature);
          }

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

  /// Determine error type (network/ui/data/unknown)
  static String _determineErrorType(Object error, String context) {
    final errorString = error.toString().toLowerCase();
    final contextLower = context.toLowerCase();

    if (errorString.contains('network') ||
        errorString.contains('socket') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('http') ||
        contextLower.contains('network') ||
        contextLower.contains('api')) {
      return 'network';
    }

    if (errorString.contains('render') ||
        errorString.contains('widget') ||
        errorString.contains('ui') ||
        errorString.contains('layout') ||
        contextLower.contains('ui') ||
        contextLower.contains('screen')) {
      return 'ui';
    }

    if (errorString.contains('data') ||
        errorString.contains('parse') ||
        errorString.contains('json') ||
        errorString.contains('serialize') ||
        contextLower.contains('data')) {
      return 'data';
    }

    return 'unknown';
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
