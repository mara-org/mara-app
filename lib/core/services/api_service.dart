import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/api_responses.dart';
import '../network/api_exceptions.dart';

/// API service for backend communication.
///
/// Handles all HTTP requests to the backend API.
/// Uses Firebase ID tokens for authentication.
class ApiService {
  /// Base URL for TestFlight (Render deployment).
  ///
  /// For production, update to: https://api.iammara.com
  static const String baseUrl = 'https://mara-api-uoum.onrender.com';

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get Firebase ID token for authentication.
  ///
  /// Forces token refresh to ensure we have a valid, non-expired token.
  /// Returns null if user is not signed in.
  Future<String?> _getFirebaseToken() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await user.getIdToken(true); // force refresh
    }
    return null;
  }

  /// Handle HTTP response with improved error handling.
  ///
  /// Parses successful responses and throws ApiException for errors.
  /// Uses Aziz's existing exception system for consistency.
  Future<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) parser,
  ) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return parser(jsonData);
      } catch (e) {
        throw UnknownApiException('Failed to parse response: $e');
      }
    } else {
      Map<String, dynamic>? errorData;
      try {
        errorData = jsonDecode(response.body) as Map<String, dynamic>?;
      } catch (_) {
        // If response body is not JSON, use empty error data
      }

      String? errorMessage;
      if (errorData != null) {
        final errorObj = errorData['error'];
        if (errorObj is Map<String, dynamic>) {
          errorMessage = errorObj['message'] as String?;
        } else if (errorObj is String) {
          errorMessage = errorObj;
        } else if (errorData['message'] is String) {
          errorMessage = errorData['message'] as String;
        }
      }

      // Map to Aziz's existing exception types
      switch (response.statusCode) {
        case 401:
          throw UnauthorizedException(errorMessage);
        case 403:
          final reason = errorData?['error']?['reason'] as String?;
          throw ForbiddenException(errorMessage, reason);
        case 429:
          // Try to parse retry-after header if available
          final retryAfter = response.headers['retry-after'];
          Duration? retryDuration;
          if (retryAfter != null) {
            final seconds = int.tryParse(retryAfter);
            if (seconds != null) {
              retryDuration = Duration(seconds: seconds);
            }
          }
          throw RateLimitException(errorMessage, retryDuration);
        case 500:
        case 502:
        case 503:
        case 504:
          throw ServerException(errorMessage);
        default:
          if (response.statusCode >= 500) {
            throw ServerException(errorMessage);
          }
          throw UnknownApiException(errorMessage);
      }
    }
  }

  // ========================================================================
  // HEALTH CHECK (بدون auth)
  // ========================================================================

  /// Check backend health status.
  ///
  /// GET /health
  Future<Map<String, dynamic>> checkHealth() async {
    final response = await http.get(
      Uri.parse('$baseUrl/health'),
    );

    return _handleResponse<Map<String, dynamic>>(
      response,
      (json) => json,
    );
  }

  /// Check backend readiness.
  ///
  /// GET /ready
  Future<Map<String, dynamic>> checkReady() async {
    final response = await http.get(
      Uri.parse('$baseUrl/ready'),
    );

    return _handleResponse<Map<String, dynamic>>(
      response,
      (json) => json,
    );
  }

  // ========================================================================
  // AUTHENTICATION ENDPOINTS (مع Firebase token)
  // ========================================================================

  /// Get user session information.
  ///
  /// POST /api/v1/auth/session
  Future<SessionResponse> getSession() async {
    final token = await _getFirebaseToken();
    if (token == null) {
      throw UnauthorizedException('User not authenticated');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/session'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return _handleResponse<SessionResponse>(
      response,
      (json) => SessionResponse.fromJson(json),
    );
  }

  /// Get current user profile.
  ///
  /// GET /api/v1/auth/me
  Future<MeResponse> getCurrentUser() async {
    final token = await _getFirebaseToken();
    if (token == null) {
      throw UnauthorizedException('User not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/auth/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return _handleResponse<MeResponse>(
      response,
      (json) => MeResponse.fromJson(json),
    );
  }

  // ========================================================================
  // CHAT ENDPOINT (مع Firebase token)
  // ========================================================================

  /// Send chat message to AI.
  ///
  /// POST /api/v1/chat
  ///
  /// [message] - User's message text (required)
  /// [conversationId] - Optional conversation ID for continuing a thread
  /// [safetyLevel] - Optional safety level: "low", "medium", "high", "strict"
  /// [maxTokens] - Optional maximum tokens for response
  /// [temperature] - Optional temperature for response generation (0.0-1.0)
  Future<ChatResponse> sendChatMessage({
    required String message,
    String? conversationId,
    String? safetyLevel,
    int? maxTokens,
    double? temperature,
  }) async {
    final token = await _getFirebaseToken();
    if (token == null) {
      throw UnauthorizedException('User not authenticated');
    }

    final body = <String, dynamic>{
      'message': message,
    };
    if (conversationId != null) {
      body['conversation_id'] = conversationId;
    }
    if (safetyLevel != null) {
      body['safety_level'] = safetyLevel;
    }
    if (maxTokens != null) {
      body['max_tokens'] = maxTokens;
    }
    if (temperature != null) {
      body['temperature'] = temperature;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/chat'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    return _handleResponse<ChatResponse>(
      response,
      (json) => ChatResponse.fromJson(json),
    );
  }

  // ========================================================================
  // PROFILE ENDPOINTS (مع Firebase token)
  // ========================================================================

  /// Complete user onboarding profile.
  ///
  /// POST /api/v1/user/profile/complete
  ///
  /// Sends all collected onboarding data to backend.
  Future<OnboardingResponse> completeOnboarding({
    required String name,
    required DateTime dateOfBirth,
    required String gender, // "male" or "female"
    required int height,
    required String heightUnit, // "cm" or "in"
    required int weight,
    required String weightUnit, // "kg" or "lb"
    String? bloodType, // "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"
    required String mainGoal, // "Stay Active", "Reduce Stress", "Sleep Better", "Track My Health"
    required Map<String, bool> permissions, // {"notifications": true, "healthData": true}
  }) async {
    final token = await _getFirebaseToken();
    if (token == null) {
      throw UnauthorizedException('User not authenticated');
    }

    final body = <String, dynamic>{
      'name': name,
      'dateOfBirth': dateOfBirth.toUtc().toIso8601String(),
      'gender': gender,
      'height': height,
      'heightUnit': heightUnit,
      'weight': weight,
      'weightUnit': weightUnit,
      'mainGoal': mainGoal,
      'permissions': permissions,
    };
    if (bloodType != null) {
      body['bloodType'] = bloodType;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/user/profile/complete'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    return _handleResponse<OnboardingResponse>(
      response,
      (json) => OnboardingResponse.fromJson(json),
    );
  }

  /// Get user profile.
  ///
  /// GET /api/v1/user/profile
  Future<ProfileResponse> getUserProfile() async {
    final token = await _getFirebaseToken();
    if (token == null) {
      throw UnauthorizedException('User not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/user/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return _handleResponse<ProfileResponse>(
      response,
      (json) => ProfileResponse.fromJson(json),
    );
  }
}

