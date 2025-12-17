import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/api_config.dart';
import '../models/app_capabilities.dart';
import '../network/api_client.dart';
import '../network/api_exceptions.dart';
import '../utils/firebase_auth_helper.dart';
import '../utils/logger.dart';

/// Service for managing backend session after Firebase authentication.
///
/// Handles:
/// - Creating backend session with Firebase token
/// - Storing user capabilities (profile, plan, entitlements, limits)
/// - Refreshing session when needed
class SessionService {
  final ApiClient _apiClient;
  AppCapabilities? _cachedCapabilities;

  SessionService(this._apiClient);

  /// Create backend session after Firebase sign-in.
  ///
  /// Gets Firebase ID token and calls POST /v1/auth/session.
  /// Returns [AppCapabilities] with user profile, plan, entitlements, and limits.
  /// Throws [ApiException] on error.
  Future<AppCapabilities> createSession() async {
    try {
      // Step 1: Get Firebase user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw UnauthorizedException('No Firebase user signed in');
      }

      // Step 2: Get fresh Firebase ID token
      final idToken = await user.getIdToken(true);
      if (idToken == null || idToken.isEmpty) {
        throw UnauthorizedException('Failed to get Firebase token');
      }

      Logger.info(
        'Creating backend session',
        feature: 'auth',
        screen: 'session_service',
        extra: {'user_id': user.uid},
      );

      // Step 3: Call backend session endpoint
      final response = await _apiClient.dio.post(
        ApiConfig.sessionEndpoint,
        data: {
          'id_token': idToken,
        },
        options: Options(
          headers: {
            ApiConfig.authorizationHeader: '${ApiConfig.bearerPrefix}$idToken',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse response
        final capabilities = AppCapabilities.fromJson(response.data);

        // Cache capabilities
        _cachedCapabilities = capabilities;

        Logger.info(
          'Backend session created successfully',
          feature: 'auth',
          screen: 'session_service',
          extra: {
            'user_id': capabilities.profile.id,
            'plan': capabilities.plan,
            'remaining_messages': capabilities.limits.remainingMessagesToday,
          },
        );

        return capabilities;
      } else {
        throw UnknownApiException(
          'Unexpected status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      final apiException = mapDioException(e);

      Logger.error(
        'Backend session creation failed',
        feature: 'auth',
        screen: 'session_service',
        error: apiException,
        extra: {'status_code': apiException.statusCode},
      );

      // Map to user-friendly error
      if (apiException is UnauthorizedException) {
        rethrow;
      } else if (apiException is NetworkException) {
        throw NetworkException('Backend unavailable. Please check your connection.');
      } else if (apiException is ServerException) {
        throw ServerException('Backend unavailable. Please try again later.');
      } else {
        throw ServerException('Backend unavailable. Please try again later.');
      }
    } catch (e) {
      if (e is ApiException) rethrow;

      Logger.error(
        'Unexpected error creating backend session',
        feature: 'auth',
        screen: 'session_service',
        error: e,
      );

      throw ServerException('Backend unavailable. Please try again later.');
    }
  }

  /// Refresh backend session (re-fetch capabilities).
  ///
  /// Useful when user's plan or limits may have changed.
  Future<AppCapabilities> refreshSession() async {
    _cachedCapabilities = null; // Clear cache
    return await createSession();
  }

  /// Get cached capabilities (if available).
  AppCapabilities? getCachedCapabilities() => _cachedCapabilities;

  /// Clear cached capabilities (on sign out).
  void clearCapabilities() {
    _cachedCapabilities = null;
  }
}

