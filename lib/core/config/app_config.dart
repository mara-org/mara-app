import 'package:flutter/foundation.dart';

/// App environment configuration.
///
/// Supports: dev, staging (TestFlight), prod
enum AppEnvironment {
  dev,
  staging,
  prod,
}

/// Centralized app configuration.
///
/// Base URL and other settings based on environment.
class AppConfig {
  AppConfig._();

  /// Current environment.
  ///
  /// Set via --dart-define=ENV=dev|staging|prod
  /// Defaults to staging (Render backend) for all builds
  static AppEnvironment get environment {
    const envString = String.fromEnvironment('ENV', defaultValue: '');

    if (envString.isEmpty) {
      // Always default to staging (Render backend) - no localhost fallback
      return AppEnvironment.staging;
    }

    switch (envString.toLowerCase()) {
      case 'dev':
      case 'development':
        return AppEnvironment.dev;
      case 'staging':
      case 'testflight':
        return AppEnvironment.staging;
      case 'prod':
      case 'production':
        return AppEnvironment.prod;
      default:
        // Default to staging (Render backend) if unknown
        return AppEnvironment.staging;
    }
  }

  /// Base URL for backend API.
  ///
  /// BASE_URL constant: https://mara-api-uoum.onrender.com
  /// Can be overridden via --dart-define=API_BASE_URL=<url>
  static const String BASE_URL = 'https://mara-api-uoum.onrender.com';

  static String get baseUrl {
    // Check for explicit override first
    const overrideUrl =
        String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (overrideUrl.isNotEmpty) {
      return overrideUrl;
    }

    // Always use Render backend - no localhost fallback
    // This ensures the app always connects to the backend, not localhost
    return BASE_URL;
  }

  /// Health check endpoint.
  static const String healthEndpoint = '/health';

  /// Version endpoint.
  static const String versionEndpoint = '/version';

  /// Session endpoint.
  /// Note: Backend might use /api/v1/auth/session - check backend docs
  static const String sessionEndpoint = '/api/v1/auth/session';

  /// Get current user endpoint.
  /// Note: Backend might use /api/v1/auth/me - check backend docs
  static const String getCurrentUserEndpoint = '/api/v1/auth/me';

  /// Chat endpoint.
  /// Note: Use ApiConfig.chatEndpoint instead - this is deprecated
  static const String chatEndpoint = '/api/v1/chat';

  /// Get environment name for display.
  static String get environmentName {
    switch (environment) {
      case AppEnvironment.dev:
        return 'Development';
      case AppEnvironment.staging:
        return 'Staging (TestFlight)';
      case AppEnvironment.prod:
        return 'Production';
    }
  }

  /// Check if running in debug mode.
  static bool get isDebug => kDebugMode;

  /// Check if running in staging/TestFlight.
  static bool get isStaging => environment == AppEnvironment.staging;

  /// Android package name.
  ///
  /// Can be overridden via --dart-define=ANDROID_PACKAGE_NAME=<name>
  static String get androidPackageName {
    const override =
        String.fromEnvironment('ANDROID_PACKAGE_NAME', defaultValue: '');
    if (override.isNotEmpty) {
      return override;
    }
    // Default package name - update when Android app is configured
    return 'com.mara.app';
  }

  /// iOS App Store ID.
  ///
  /// Can be overridden via --dart-define=IOS_APP_ID=<id>
  static String get iosAppId {
    const override = String.fromEnvironment('IOS_APP_ID', defaultValue: '');
    if (override.isNotEmpty) {
      return override;
    }
    // Default App Store ID - update when iOS app is published
    return '1234567890';
  }
}
