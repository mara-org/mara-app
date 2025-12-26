import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../config/app_config.dart';
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
    final baseUrl = ApiConfig.baseUrl;
    debugPrint('🔧 ApiClient: Initializing with baseUrl: $baseUrl');
    debugPrint('🔧 ApiClient: Environment: ${AppConfig.environmentName}');

    // Confirm backend URL is set correctly
    if (baseUrl == 'https://mara-api-uoum.onrender.com') {
      debugPrint('✅ ApiClient: Backend URL configured: Render backend');
    } else {
      debugPrint(
          '⚠️ ApiClient: Backend URL: $baseUrl (expected: https://mara-api-uoum.onrender.com)');
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        // Increased timeouts for Render free tier (services sleep and take 30-90s to wake up)
        connectTimeout: const Duration(seconds: 90),
        receiveTimeout: const Duration(seconds: 90),
        sendTimeout: const Duration(seconds: 90),
        headers: {
          'Content-Type': ApiConfig.contentTypeHeader,
        },
      ),
    );

    // Add request logging interceptor FIRST (so it logs everything)
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final fullUrl = '${options.baseUrl}${options.path}';
          final timestamp = DateTime.now();

          // Log full request details
          debugPrint('═══════════════════════════════════════════════════════');
          debugPrint('🌐 API REQUEST');
          debugPrint('═══════════════════════════════════════════════════════');
          debugPrint('📍 Method: ${options.method}');
          debugPrint('📍 Full URL: $fullUrl');
          debugPrint('📍 Base URL: ${options.baseUrl}');
          debugPrint('📍 Path: ${options.path}');
          debugPrint('📍 Full URI: ${options.uri}');
          debugPrint('📍 Timestamp: $timestamp');

          // Log headers (without secrets)
          final safeHeaders = Map<String, dynamic>.from(options.headers);
          if (safeHeaders.containsKey('Authorization')) {
            final auth = safeHeaders['Authorization'] as String?;
            if (auth != null && auth.length > 20) {
              safeHeaders['Authorization'] = '${auth.substring(0, 20)}...';
            }
          }
          debugPrint('📤 Headers: $safeHeaders');
          debugPrint('📤 Content-Type: ${options.headers['Content-Type']}');

          // Log body keys (not secrets)
          if (options.data != null) {
            if (options.data is Map) {
              final dataMap = options.data as Map;
              final keys = dataMap.keys.toList();
              // Mask sensitive keys
              final safeKeys = keys.map((key) {
                final value = dataMap[key];
                if (key.toString().toLowerCase().contains('password') ||
                    key.toString().toLowerCase().contains('token') ||
                    key.toString().toLowerCase().contains('secret')) {
                  return '$key: [REDACTED]';
                }
                return '$key: ${value.toString().length > 50 ? value.toString().substring(0, 50) + "..." : value}';
              }).toList();
              debugPrint('📤 Body keys: $keys');
              debugPrint('📤 Body values (safe): $safeKeys');
            } else {
              final bodyStr = options.data.toString();
              final bodyPreview = bodyStr.length > 500
                  ? '${bodyStr.substring(0, 500)}...'
                  : bodyStr;
              debugPrint('📤 Body: $bodyPreview');
            }
            debugPrint('📤 Body type: ${options.data.runtimeType}');
          } else {
            debugPrint('📤 Body: null');
          }
          debugPrint('═══════════════════════════════════════════════════════');

          return handler.next(options);
        },
        onResponse: (response, handler) {
          final fullUrl =
              '${response.requestOptions.baseUrl}${response.requestOptions.path}';
          final bodyStr = response.data?.toString() ?? 'null';
          final bodyPreview = bodyStr.length > 500
              ? '${bodyStr.substring(0, 500)}...'
              : bodyStr;

          debugPrint('═══════════════════════════════════════════════════════');
          debugPrint('✅ API RESPONSE');
          debugPrint('═══════════════════════════════════════════════════════');
          debugPrint('📍 Method: ${response.requestOptions.method}');
          debugPrint('📍 Full URL: $fullUrl');
          debugPrint('📍 Status Code: ${response.statusCode}');
          debugPrint('📥 Headers: ${response.headers}');
          debugPrint('📥 Body: $bodyPreview');
          debugPrint('═══════════════════════════════════════════════════════');

          return handler.next(response);
        },
        onError: (error, handler) {
          final timestamp = DateTime.now();
          debugPrint('❌ ApiClient: ERROR at $timestamp');
          debugPrint(
              '❌ ApiClient: ${error.requestOptions.method} ${error.requestOptions.path}');
          debugPrint('❌ ApiClient: Error type: ${error.type}');
          debugPrint('❌ ApiClient: Error message: ${error.message}');
          debugPrint('❌ ApiClient: Request URI: ${error.requestOptions.uri}');
          debugPrint(
              '❌ ApiClient: Request baseUrl: ${error.requestOptions.baseUrl}');
          debugPrint('❌ ApiClient: Status: ${error.response?.statusCode}');
          debugPrint(
              '❌ ApiClient: Response headers: ${error.response?.headers}');
          debugPrint('❌ ApiClient: Response: ${error.response?.data}');

          // Critical check: Did request reach server?
          if (error.response != null) {
            debugPrint(
                '✅ ApiClient: Request REACHED server (got HTTP response)');
          } else {
            debugPrint(
                '❌ ApiClient: Request DID NOT reach server (no HTTP response)');
            if (error.type == DioExceptionType.connectionTimeout) {
              debugPrint(
                  '❌ ApiClient: Connection timeout - server may be down or unreachable');
            } else if (error.type == DioExceptionType.connectionError) {
              debugPrint(
                  '❌ ApiClient: Connection error - cannot establish connection');
            }
          }

          return handler.next(error);
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
            debugPrint('🔑 ApiClient: Added Firebase token to request');
          } else {
            debugPrint(
                '⚠️ ApiClient: No Firebase token available (unauthenticated request)');
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
