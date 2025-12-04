import '../models/auth_result.dart';
import '../../../../core/utils/logger.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing up a new user.
///
/// This encapsulates the business logic for user registration.
class SignUpUseCase {
  final AuthRepository _authRepository;

  SignUpUseCase(this._authRepository);

  /// Signs up a new user with email and password.
  ///
  /// Returns [AuthResult] indicating success or failure.
  /// Logs the operation for observability.
  Future<AuthResult> execute({
    required String email,
    required String password,
    String? displayName,
  }) async {
    Logger.info(
      'Sign-up attempt',
      feature: 'auth',
      screen: 'sign_up',
      extra: {'email': email}, // Note: Never log passwords
    );

    try {
      final result = await _authRepository.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (result.isSuccess && result.user != null) {
        Logger.info(
          'Sign-up successful',
          feature: 'auth',
          screen: 'sign_up',
          extra: {'userId': result.user!.id},
        );
      } else {
        Logger.warning(
          'Sign-up failed',
          feature: 'auth',
          screen: 'sign_up',
          extra: {
            'error': result.errorMessage,
            'errorType': result.errorType?.toString()
          },
        );
      }

      return result;
    } catch (e, stackTrace) {
      Logger.error(
        'Sign-up error',
        feature: 'auth',
        screen: 'sign_up',
        error: e,
        stackTrace: stackTrace,
      );

      return AuthResult.failureResult(
        'An unexpected error occurred. Please try again.',
        AuthErrorType.unknown,
      );
    }
  }
}
