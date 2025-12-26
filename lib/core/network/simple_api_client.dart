import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/app_config.dart';

/// Simple API client for backend calls.
/// 
/// Handles:
/// - Base URL configuration
/// - Authorization header with Firebase token
/// - 401 error handling (force logout)
class SimpleApiClient {
  late final Dio _dio;
  
  SimpleApiClient() {
    final baseUrl = AppConfig.baseUrl;
    debugPrint('🔧 SimpleApiClient: Initializing with baseUrl: $baseUrl');
    debugPrint('🔧 SimpleApiClient: Environment: ${AppConfig.environmentName}');
    
    // Confirm backend URL is set correctly
    if (baseUrl == 'https://mara-api-uoum.onrender.com') {
      debugPrint('✅ Backend URL configured: Render backend');
    } else {
      debugPrint('⚠️ Backend URL: $baseUrl (expected: https://mara-api-uoum.onrender.com)');
    }
    
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        // Increased timeouts for Render free tier (services sleep and take 30-60s to wake up)
        connectTimeout: const Duration(seconds: 90),
        receiveTimeout: const Duration(seconds: 90),
        sendTimeout: const Duration(seconds: 90),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Interceptor to add Authorization header and handle 401
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Log request details for session endpoint
          if (options.path.contains('/session')) {
            debugPrint('🔍 Interceptor: Processing session request');
            debugPrint('🔍 Interceptor: Method: ${options.method}');
            debugPrint('🔍 Interceptor: Path: ${options.path}');
            debugPrint('🔍 Interceptor: Base URL: ${options.baseUrl}');
            debugPrint('🔍 Interceptor: Full URL: ${options.uri}');
            debugPrint('🔍 Interceptor: Headers before: ${options.headers.keys.toList()}');
            debugPrint('🔍 Interceptor: Data type: ${options.data.runtimeType}');
            if (options.data is Map) {
              debugPrint('🔍 Interceptor: Data: ${options.data}');
            }
          }
          
          // Ensure Content-Type is set
          if (!options.headers.containsKey('Content-Type')) {
            options.headers['Content-Type'] = 'application/json';
          }
          
          // Get fresh Firebase token
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            try {
              final token = await user.getIdToken(true);
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
                // Log token presence for session endpoint (debug only)
                if (options.path.contains('/session')) {
                  final endpointType = 'Session';
                  debugPrint('✅ $endpointType request: Firebase token included (length: ${token.length})');
                  debugPrint('✅ $endpointType request: Authorization header set');
                  debugPrint('✅ $endpointType request: Content-Type: ${options.headers['Content-Type']}');
                  debugPrint('✅ $endpointType request: All headers: ${options.headers.keys.toList()}');
                  debugPrint('✅ $endpointType request: Full URL: ${options.uri}');
                }
              } else {
                if (options.path.contains('/session')) {
                  debugPrint('⚠️ Request: Token is null or empty');
                }
              }
            } catch (e) {
              // Token refresh failed
              if (options.path.contains('/session')) {
                debugPrint('⚠️ Request: Token refresh failed: $e');
              }
            }
          } else {
            // No user signed in
            if (options.path.contains('/session')) {
              debugPrint('⚠️ Request: No Firebase user signed in - request will fail with 401');
            }
          }
          
          // Log final request details for session endpoint
          if (options.path.contains('/session')) {
            debugPrint('🔍 Interceptor: Headers after: ${options.headers.keys.toList()}');
            debugPrint('🔍 Interceptor: Final URL: ${options.uri}');
          }
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log response for session endpoint
          if (response.requestOptions.path.contains('/session')) {
            debugPrint('✅ Interceptor: Response received');
            debugPrint('✅ Interceptor: Status code: ${response.statusCode}');
            debugPrint('✅ Interceptor: Response data type: ${response.data.runtimeType}');
            if (response.data is Map) {
              debugPrint('✅ Interceptor: Response keys: ${(response.data as Map).keys.toList()}');
            }
          }
          return handler.next(response);
        },
        onError: (error, handler) async {
          // Log error details for session endpoint
          if (error.requestOptions.path.contains('/session')) {
            debugPrint('❌ Interceptor: Error occurred');
            debugPrint('❌ Interceptor: Error type: ${error.type}');
            debugPrint('❌ Interceptor: Response status: ${error.response?.statusCode}');
            debugPrint('❌ Interceptor: Request URI: ${error.requestOptions.uri}');
            debugPrint('❌ Interceptor: Request reached server: ${error.response != null}');
            if (error.response != null) {
              debugPrint('❌ Interceptor: Response data: ${error.response!.data}');
            debugPrint('❌ Interceptor: Response data type: ${error.response!.data.runtimeType}');
            if (error.response!.data is Map) {
              final errorData = error.response!.data as Map;
              debugPrint('❌ Interceptor: Error keys: ${errorData.keys.toList()}');
              if (errorData.containsKey('error')) {
                final backendError = errorData['error'];
                if (backendError is Map) {
                  debugPrint('❌ Interceptor: Backend error message: ${backendError['message']}');
                  debugPrint('❌ Interceptor: Backend error code: ${backendError['code']}');
                  debugPrint('❌ Interceptor: Backend error type: ${backendError['type']}');
                  debugPrint('❌ Interceptor: Correlation ID: ${backendError['correlation_id']}');
                }
              }
            }
            } else {
              debugPrint('❌ Interceptor: No response - request may not have reached backend');
            }
          }
          
          // Handle 401 - force logout (except for session endpoint during sign-in)
          if (error.response?.statusCode == 401) {
            final isSessionEndpoint = error.requestOptions.path.contains('/session');
            if (!isSessionEndpoint) {
              // Only force logout for non-session endpoints
              // Session 401 during sign-in is expected and handled by auth screens
              await FirebaseAuth.instance.signOut();
              // Navigate to sign-in (handled by app state)
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// POST request to backend.
  /// 
  /// [path] - API endpoint path (e.g., '/v1/auth/session')
  /// [body] - Request body as Map
  /// [headers] - Optional additional headers
  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final baseUrl = AppConfig.baseUrl;
    final fullUrl = '$baseUrl$path';
    debugPrint('🌐 SimpleApiClient: POST $fullUrl');
    debugPrint('📤 Body keys: ${body.keys.toList()}');
    
    // Log full request body for debugging (session endpoint)
    if (path.contains('/session')) {
      debugPrint('📤 Request body: $body');
      // Log each field separately for clarity
      body.forEach((key, value) {
        if (value is Map) {
          debugPrint('   $key: ${value.toString().substring(0, value.toString().length > 100 ? 100 : value.toString().length)}...');
        } else {
          debugPrint('   $key: $value');
        }
      });
    }
    
    try {
      // Log exact request details before sending
      debugPrint('📡 SimpleApiClient: About to send POST request');
      debugPrint('📡 Path: $path');
      debugPrint('📡 Base URL: $baseUrl');
      debugPrint('📡 Full URL will be: $fullUrl');
      debugPrint('📡 Request body (JSON): ${jsonEncode(body)}');
      debugPrint('📡 Headers: ${headers?.toString() ?? 'none (using defaults)'}');
      
      final response = await _dio.post(
        path,
        data: body,
        options: Options(
          headers: headers,
        ),
      );
      
      debugPrint('✅ SimpleApiClient: POST success (${response.statusCode})');
      debugPrint('📥 Response keys: ${response.data is Map ? (response.data as Map).keys.toList() : 'not a map'}');

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else {
        debugPrint('⚠️ SimpleApiClient: Response is not a Map');
        return {'error': 'Invalid response format'};
      }
    } on DioException catch (e) {
      // Full logging for all endpoints
      debugPrint('❌ SimpleApiClient: DioException on POST $fullUrl');
        debugPrint('❌ Type: ${e.type}');
        debugPrint('❌ Message: ${e.message}');
        debugPrint('❌ Response status: ${e.response?.statusCode}');
        debugPrint('❌ Response data: ${e.response?.data}');
        debugPrint('❌ Request path: ${e.requestOptions.path}');
        debugPrint('❌ Request baseUrl: ${e.requestOptions.baseUrl}');
        debugPrint('❌ Request URI: ${e.requestOptions.uri}');
        debugPrint('❌ Request headers: ${e.requestOptions.headers}');
        debugPrint('❌ Request data: ${e.requestOptions.data}');
        debugPrint('❌ Request method: ${e.requestOptions.method}');
        
        // Check if request was actually sent
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError) {
          debugPrint('⚠️ Network error detected - request may not have reached backend');
          debugPrint('⚠️ This could mean:');
          debugPrint('   - Backend is down or unreachable');
          debugPrint('   - Network connectivity issue');
          debugPrint('   - Firewall blocking request');
          debugPrint('   - DNS resolution failure');
        }
      
      // Handle network errors gracefully
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        final errorMsg = 'Network error: Unable to connect to backend. Please check your internet connection.';
        debugPrint('❌ $errorMsg');
        throw Exception(errorMsg);
      }
      
      // Handle HTTP errors
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        if (statusCode == 404) {
          throw Exception('Endpoint not found. Please check backend configuration.');
        } else if (statusCode == 401) {
          throw Exception('Authentication failed. Please sign in again.');
        } else if (statusCode == 403) {
          // Check if it's a device limit error
          if (e.response!.data is Map<String, dynamic>) {
            final errorData = e.response!.data as Map<String, dynamic>;
            final errorCode = errorData['error']?['reason'] as String?;
            if (errorCode == 'DEVICE_LIMIT_EXCEEDED') {
              // Return error data so SessionService can extract device limit info
              return errorData;
            }
          }
          throw Exception('Access denied. Please check your permissions.');
        } else if (statusCode == 500) {
          // Extract detailed error message from backend response
          String errorMsg = 'Backend server error. Please try again later.';
          if (e.response!.data is Map<String, dynamic>) {
            final errorData = e.response!.data as Map<String, dynamic>;
            final backendError = errorData['error'];
            if (backendError is Map) {
              final backendMsg = backendError['message'] as String?;
              final correlationId = backendError['correlation_id'] as String?;
              if (backendMsg != null) {
                errorMsg = backendMsg;
                debugPrint('❌ Backend 500 error message: $backendMsg');
                if (correlationId != null) {
                  debugPrint('❌ Correlation ID: $correlationId');
                }
              }
            }
          }
          debugPrint('❌ Full backend 500 response: ${e.response!.data}');
          throw Exception(errorMsg);
        } else if (e.response!.data is Map<String, dynamic>) {
          return e.response!.data as Map<String, dynamic>;
        } else {
          throw Exception('Backend error (${statusCode}): ${e.response!.data ?? e.message}');
        }
      }
      
      rethrow;
    } catch (e) {
      // Wrap any other errors
      debugPrint('❌ SimpleApiClient: Unexpected error: $e');
      throw Exception('Service unavailable: ${e.toString()}');
    }
  }

  /// GET request to backend.
  /// 
  /// [path] - API endpoint path (e.g., '/health')
  /// [headers] - Optional additional headers
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    final baseUrl = AppConfig.baseUrl;
    final fullUrl = '$baseUrl$path';
    debugPrint('🌐 SimpleApiClient: GET $fullUrl');
    
    try {
      final response = await _dio.get(
        path,
        options: Options(
          headers: headers,
        ),
      );
      
      debugPrint('✅ SimpleApiClient: GET success (${response.statusCode})');
      debugPrint('📥 Response keys: ${response.data is Map ? (response.data as Map).keys.toList() : 'not a map'}');

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else {
        return {'status': 'ok', 'data': response.data.toString()};
      }
    } on DioException catch (e) {
      debugPrint('❌ SimpleApiClient: DioException on GET $fullUrl');
      debugPrint('❌ Type: ${e.type}');
      debugPrint('❌ Message: ${e.message}');
      debugPrint('❌ Response status: ${e.response?.statusCode}');
      debugPrint('❌ Response data: ${e.response?.data}');
      debugPrint('❌ Request path: ${e.requestOptions.path}');
      debugPrint('❌ Request baseUrl: ${e.requestOptions.baseUrl}');
      
      // Handle network errors gracefully
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        final errorMsg = 'Network error: Unable to connect to backend. Please check your internet connection.';
        debugPrint('❌ $errorMsg');
        throw Exception(errorMsg);
      }
      
      // Handle HTTP errors
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        if (statusCode == 404) {
          throw Exception('Endpoint not found. Please check backend configuration.');
        } else if (statusCode == 401) {
          throw Exception('Authentication failed. Please sign in again.');
        } else if (statusCode == 403) {
          throw Exception('Access denied. Please check your permissions.');
        } else if (statusCode == 500) {
          throw Exception('Backend server error. Please try again later.');
        } else if (e.response!.data is Map<String, dynamic>) {
          return e.response!.data as Map<String, dynamic>;
        } else {
          throw Exception('Backend error (${statusCode}): ${e.response!.data ?? e.message}');
        }
      }
      
      rethrow;
    } catch (e) {
      // Wrap any other errors
      debugPrint('❌ SimpleApiClient: Unexpected error: $e');
      throw Exception('Service unavailable: ${e.toString()}');
    }
  }
}


