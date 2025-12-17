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
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Interceptor to add Authorization header and handle 401
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get fresh Firebase token
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            try {
              final token = await user.getIdToken(true);
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            } catch (e) {
              // Token refresh failed, continue without token
            }
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 - force logout
          if (error.response?.statusCode == 401) {
            await FirebaseAuth.instance.signOut();
            // Navigate to sign-in (handled by app state)
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
    try {
      final response = await _dio.post(
        path,
        data: body,
        options: Options(
          headers: headers,
        ),
      );

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else {
        return {'error': 'Invalid response format'};
      }
    } on DioException catch (e) {
      // Handle network errors gracefully
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Service unavailable. Please check your connection.');
      }
      
      if (e.response != null && e.response!.data is Map<String, dynamic>) {
        return e.response!.data as Map<String, dynamic>;
      }
      rethrow;
    } catch (e) {
      // Wrap any other errors
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
    try {
      final response = await _dio.get(
        path,
        options: Options(
          headers: headers,
        ),
      );

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else {
        return {'status': 'ok', 'data': response.data.toString()};
      }
    } on DioException catch (e) {
      // Handle network errors gracefully
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Service unavailable. Please check your connection.');
      }
      
      if (e.response != null && e.response!.data is Map<String, dynamic>) {
        return e.response!.data as Map<String, dynamic>;
      }
      rethrow;
    } catch (e) {
      // Wrap any other errors
      throw Exception('Service unavailable: ${e.toString()}');
    }
  }
}

