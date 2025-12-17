import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'app_config.dart';

/// API configuration for backend integration.
///
/// Uses [AppConfig] for base URL configuration.
/// Falls back to platform-specific defaults only in debug mode for local development.
///
/// For production, API_BASE_URL can be provided via --dart-define, or uses environment defaults.
class ApiConfig {
  ApiConfig._();

  /// Base URL for API requests.
  ///
  /// Uses [AppConfig.baseUrl] which supports:
  /// - Override via --dart-define=API_BASE_URL=<url>
  /// - Environment-based defaults (dev, staging, prod)
  /// - Platform-specific localhost fallback in debug mode
  static String get baseUrl {
    // Use AppConfig for consistent base URL management
    return AppConfig.baseUrl;
  }

  /// API endpoints - Firebase Authentication
  static const String registerEndpoint = '/api/v1/auth/register';
  static const String loginEndpoint = '/api/v1/auth/login';
  static const String sessionEndpoint = '/v1/auth/session';
  static const String getCurrentUserEndpoint = '/api/v1/auth/me';
  
  /// Legacy endpoints (kept for backward compatibility if needed)
  static const String signupEndpoint = '/api/v1/auth/signup';
  static const String signinEndpoint = '/api/v1/auth/signin';
  static const String verifyEmailEndpoint = '/api/v1/auth/verify-email';
  static const String resendVerificationEndpoint = '/api/v1/auth/resend-verification-code';
  static const String forgotPasswordEndpoint = '/api/v1/auth/forgot-password';
  static const String verifyPasswordResetCodeEndpoint = '/api/v1/auth/verify-password-reset-code';
  static const String resetPasswordEndpoint = '/api/v1/auth/reset-password';
  static const String signoutEndpoint = '/api/v1/auth/signout';

  /// Chat endpoints
  static const String chatEndpoint = '/v1/chat';

  /// Health & Status
  static const String healthEndpoint = '/health';
  static const String docsEndpoint = '/docs';

  /// Headers
  static const String contentTypeHeader = 'application/json';
  static const String authorizationHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';
  static const String requestIdHeader = 'x-request-id';
}

