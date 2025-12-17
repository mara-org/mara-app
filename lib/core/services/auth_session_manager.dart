import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_capabilities.dart';
import '../providers/app_capabilities_provider.dart';
import '../services/session_service.dart';
import '../network/api_exceptions.dart';
import '../utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manager for coordinating Firebase auth and backend session creation.
///
/// This is called after Firebase sign-in to create backend session
/// and load user capabilities.
class AuthSessionManager {
  final SessionService _sessionService;
  final Ref _ref;

  AuthSessionManager(this._sessionService, this._ref);

  /// Create backend session after Firebase sign-in.
  ///
  /// This should be called immediately after successful Firebase authentication.
  /// It will:
  /// 1. Get Firebase ID token
  /// 2. Call POST /v1/auth/session
  /// 3. Store capabilities in AppCapabilitiesProvider
  ///
  /// Throws [ApiException] on error (with user-friendly messages).
  Future<AppCapabilities> createSessionAfterSignIn() async {
    try {
      // Get Firebase user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw UnauthorizedException('No Firebase user signed in');
      }

      // Get fresh Firebase ID token
      final idToken = await user.getIdToken(true);
      if (idToken == null || idToken.isEmpty) {
        throw UnauthorizedException('Failed to get Firebase token');
      }

      Logger.info(
        'Creating backend session after Firebase sign-in',
        feature: 'auth',
        screen: 'auth_session_manager',
        extra: {'user_id': user.uid},
      );

      // Create backend session
      final capabilities = await _sessionService.createSession();

      // Store in provider
      _ref.read(appCapabilitiesProvider.notifier).updateCapabilities(capabilities);

      Logger.info(
        'Backend session created and stored',
        feature: 'auth',
        screen: 'auth_session_manager',
        extra: {
          'user_id': capabilities.profile.id,
          'plan': capabilities.plan,
        },
      );

      return capabilities;
    } on ApiException catch (e) {
      Logger.error(
        'Backend session creation failed',
        feature: 'auth',
        screen: 'auth_session_manager',
        error: e,
      );

      // Re-throw with user-friendly message
      if (e is NetworkException || e is ServerException) {
        throw ServerException('Backend unavailable. Please try again later.');
      }
      rethrow;
    } catch (e) {
      Logger.error(
        'Unexpected error creating backend session',
        feature: 'auth',
        screen: 'auth_session_manager',
        error: e,
      );
      throw ServerException('Backend unavailable. Please try again later.');
    }
  }
}

