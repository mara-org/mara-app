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

  /// API endpoints - All use versioned /api/v1/ prefix

  /// Authentication endpoints (as per backend API spec)
  /// POST /api/v1/auth/register - Sign up with Firebase ID token
  static const String registerEndpoint = '/api/v1/auth/register';

  /// POST /api/v1/auth/session - Create session (sign in) with device tracking
  static const String sessionEndpoint = '/api/v1/auth/session';

  /// GET /api/v1/auth/me - Get current user profile
  static const String getCurrentUserEndpoint = '/api/v1/auth/me';

  /// Account deletion endpoint
  /// DELETE /api/v1/user/profile - Soft delete account (no code required)
  static const String deleteAccountEndpoint = '/api/v1/user/profile';

  /// Chat endpoints
  static const String chatEndpoint = '/api/v1/chat';

  /// Health & Status endpoints
  static const String healthEndpoint = '/health';
  static const String readyEndpoint = '/ready';
  static const String docsEndpoint = '/docs';

  /// Headers
  static const String contentTypeHeader = 'application/json';
  static const String authorizationHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';
  static const String requestIdHeader = 'x-request-id';
}
