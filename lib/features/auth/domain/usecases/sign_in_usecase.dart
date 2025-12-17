import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/auth_result.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/services/auth_session_manager.dart';
import '../../../../core/network/api_exceptions.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in a user.
///
/// This encapsulates the business logic for authentication.
/// After Firebase sign-in, it creates backend session and loads capabilities.
class SignInUseCase {
  final AuthRepository _authRepository;
  final AuthSessionManager? _sessionManager;

  SignInUseCase(this._authRepository, [this._sessionManager]);

  /// Signs in a user with email and password.
  ///
  /// Returns [AuthResult] indicating success or failure.
  /// Logs the operation for observability.
  Future<AuthResult> execute({
    required String email,
    required String password,
  }) async {
    // Hash email for logging (never log raw email addresses)
    final emailHash = _hashEmail(email);
    Logger.info(
      'Sign-in attempt',
      feature: 'auth',
      screen: 'sign_in',
      extra: {'email_hash': emailHash}, // Never log raw email addresses
    );

    try {
      final result = await _authRepository.signIn(
        email: email,
        password: password,
      );

      if (result.isSuccess && result.user != null) {
        Logger.info(
          'Firebase sign-in successful, creating backend session',
          feature: 'auth',
          screen: 'sign_in',
          extra: {'userId': result.user!.id},
        );

        // Create backend session after Firebase sign-in
        if (_sessionManager != null) {
          try {
            await _sessionManager!.createSessionAfterSignIn();
            Logger.info(
              'Backend session created successfully',
              feature: 'auth',
              screen: 'sign_in',
            );
          } on ApiException catch (e) {
            Logger.error(
              'Backend session creation failed',
              feature: 'auth',
              screen: 'sign_in',
              error: e,
            );
            // Return success for Firebase auth, but log backend error
            // The app can still function with Firebase auth
          }
        }
      } else {
        Logger.warning(
          'Sign-in failed',
          feature: 'auth',
          screen: 'sign_in',
          extra: {
            'error': result.errorMessage,
            'errorType': result.errorType?.toString(),
          },
        );
      }

      return result;
    } on Exception catch (e, stackTrace) {
      Logger.error(
        'Sign-in error',
        feature: 'auth',
        screen: 'sign_in',
        error: e,
        stackTrace: stackTrace,
      );

      return AuthResult.failureResult(
        'An unexpected error occurred. Please try again.',
        AuthErrorType.unknown,
      );
    }
  }

  /// Hash email address for logging purposes.
  ///
  /// Uses SHA-256 to create a one-way hash. This allows correlation
  /// of logs without exposing PII.
  static String _hashEmail(final String email) {
    final bytes = utf8.encode(email.toLowerCase().trim());
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16); // First 16 chars for readability
  }
}
