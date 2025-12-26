import 'package:flutter/foundation.dart';

/// Environment configuration for the app.
///
/// All environment-dependent values must be provided via --dart-define flags.
/// This ensures no secrets or environment-specific values are hardcoded.
///
/// Usage:
/// ```bash
/// flutter run --dart-define=API_BASE_URL=https://api.example.com
/// ```
///
/// For production builds:
/// ```bash
/// flutter build apk --dart-define=API_BASE_URL=https://api.production.com
/// ```
class EnvConfig {
  EnvConfig._();

  /// API base URL for backend requests.
  ///
  /// Defaults to localhost for development if not provided.
  /// Must be set via --dart-define=API_BASE_URL=<url> for production.
  static String get apiBaseUrl {
    const value = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );

    // If not provided, use platform-specific defaults for local development
    if (value.isEmpty) {
      if (kDebugMode) {
        // Development defaults (safe for local dev only)
        if (kIsWeb) {
          return 'http://localhost:8000';
        }
        // Note: Platform detection requires dart:io, handled in ApiConfig
        return ''; // Will be handled by ApiConfig with platform detection
      } else {
        // Production: must be provided via --dart-define
        throw StateError(
          'API_BASE_URL must be provided via --dart-define in production builds. '
          'Example: flutter build apk --dart-define=API_BASE_URL=https://api.example.com',
        );
      }
    }

    return value;
  }

  /// Whether to enable crash reporting (Sentry/Crashlytics).
  ///
  /// Defaults to false. Set via --dart-define=ENABLE_CRASH_REPORTING=true
  static bool get enableCrashReporting {
    return const bool.fromEnvironment(
      'ENABLE_CRASH_REPORTING',
      defaultValue: false,
    );
  }

  /// Whether to enable analytics.
  ///
  /// Defaults to false. Set via --dart-define=ENABLE_ANALYTICS=true
  static bool get enableAnalytics {
    return const bool.fromEnvironment(
      'ENABLE_ANALYTICS',
      defaultValue: false,
    );
  }

  /// Sentry DSN for crash reporting.
  ///
  /// Must be provided via --dart-define=SENTRY_DSN=<dsn> if crash reporting is enabled.
  static String get sentryDsn {
    return const String.fromEnvironment(
      'SENTRY_DSN',
      defaultValue: '',
    );
  }

  /// Firebase project configuration.
  ///
  /// These are typically provided via firebase_options.dart (generated),
  /// but can be overridden via --dart-define if needed.
  static String get firebaseProjectId {
    return const String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: '',
    );
  }

  /// Validate that required environment variables are set.
  ///
  /// Throws [StateError] if validation fails.
  static void validate() {
    if (!kDebugMode) {
      // In production, API_BASE_URL must be provided
      try {
        final url = apiBaseUrl;
        if (url.isEmpty) {
          throw StateError(
            'API_BASE_URL must be provided via --dart-define in production',
          );
        }
      } catch (e) {
        if (e is StateError) rethrow;
      }

      // If crash reporting is enabled, DSN must be provided
      if (enableCrashReporting && sentryDsn.isEmpty) {
        throw StateError(
          'SENTRY_DSN must be provided via --dart-define when ENABLE_CRASH_REPORTING=true',
        );
      }
    }
  }
}
