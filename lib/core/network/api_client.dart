import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'retry_interceptor.dart';
import '../utils/logger.dart';
import '../utils/firebase_auth_helper.dart';

/// Centralized HTTP client for API requests.
///
/// Handles:
/// - Base URL configuration
/// - Bearer token authentication
/// - Request/response interceptors
/// - Error handling
/// - Token storage and management
class ApiClient {
  late final Dio _dio;
  static const String _accessTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': ApiConfig.contentTypeHeader,
        },
      ),
    );

    // Add retry interceptor
    _dio.interceptors.add(RetryInterceptor());

    // Add auth interceptor for Bearer token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get fresh Firebase token for authenticated requests
          final token = await FirebaseAuthHelper.getFreshFirebaseToken();
          if (token != null && token.isNotEmpty) {
            options.headers[ApiConfig.authorizationHeader] =
                '${ApiConfig.bearerPrefix}$token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          Logger.error(
            'API Error: ${error.requestOptions.path}',
            feature: 'api_client',
            error: error,
          );

          // Handle 401 Unauthorized - force re-login
          if (error.response?.statusCode == 401) {
            Logger.warning(
              '401 Unauthorized - forcing re-login',
              feature: 'api_client',
              screen: 'api_client',
              extra: {'path': error.requestOptions.path},
            );

            // Clear any cached tokens/capabilities
            await clearTokens();

            // Sign out from Firebase to force re-authentication
            try {
              await FirebaseAuth.instance.signOut();
            } catch (e) {
              Logger.error(
                'Error signing out Firebase user',
                feature: 'api_client',
                screen: 'api_client',
                error: e,
              );
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  /// Get the Dio instance.
  Dio get dio => _dio;

  /// Store authentication tokens.
  Future<void> setTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
  }

  /// Get stored access token.
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// Get stored refresh token.
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// Clear stored authentication tokens.
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  /// Health check endpoint.
  Future<Response> healthCheck() async {
    return await _dio.get(ApiConfig.healthEndpoint);
  }
}

