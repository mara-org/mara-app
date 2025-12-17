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
  /// Defaults to dev in debug mode, prod in release
  static AppEnvironment get environment {
    const envString = String.fromEnvironment('ENV', defaultValue: '');
    
    if (envString.isEmpty) {
      // Auto-detect: dev in debug, prod in release
      return kDebugMode ? AppEnvironment.dev : AppEnvironment.prod;
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
        return kDebugMode ? AppEnvironment.dev : AppEnvironment.prod;
    }
  }

  /// Base URL for backend API.
  /// 
  /// Can be overridden via --dart-define=API_BASE_URL=<url>
  /// Otherwise uses environment-specific defaults
  static String get baseUrl {
    // Check for explicit override
    const overrideUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (overrideUrl.isNotEmpty) {
      return overrideUrl;
    }

    // Use environment-specific defaults
    switch (environment) {
      case AppEnvironment.dev:
        return 'http://localhost:8000';
      case AppEnvironment.staging:
        // TestFlight staging URL (temporary - for internal testing only)
        return 'https://mara-api-uoum.onrender.com';
      case AppEnvironment.prod:
        return 'https://api.mara.app';
    }
  }

  /// Health check endpoint.
  static const String healthEndpoint = '/health';

  /// Version endpoint.
  static const String versionEndpoint = '/version';

  /// Session endpoint.
  static const String sessionEndpoint = '/v1/auth/session';

  /// Get current user endpoint.
  static const String getCurrentUserEndpoint = '/v1/auth/me';

  /// Chat endpoint.
  static const String chatEndpoint = '/v1/chat';

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
    const override = String.fromEnvironment('ANDROID_PACKAGE_NAME', defaultValue: '');
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
