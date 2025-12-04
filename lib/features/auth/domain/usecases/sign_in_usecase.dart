import '../models/auth_result.dart';
import '../../../../core/utils/logger.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in a user.
///
/// This encapsulates the business logic for authentication.
/// It does not depend on UI or data source implementations.
class SignInUseCase {
  final AuthRepository _authRepository;

  SignInUseCase(this._authRepository);

  /// Signs in a user with email and password.
  ///
  /// Returns [AuthResult] indicating success or failure.
  /// Logs the operation for observability.
  Future<AuthResult> execute({
    required String email,
    required String password,
  }) async {
    Logger.info(
      'Sign-in attempt',
      feature: 'auth',
      screen: 'sign_in',
      extra: {'email': email}, // Note: Never log passwords
    );

    try {
      final result = await _authRepository.signIn(
        email: email,
        password: password,
      );

      if (result.isSuccess && result.user != null) {
        Logger.info(
          'Sign-in successful',
          feature: 'auth',
          screen: 'sign_in',
          extra: {'userId': result.user!.id},
        );
      } else {
        Logger.warning(
          'Sign-in failed',
          feature: 'auth',
          screen: 'sign_in',
          extra: {
            'error': result.errorMessage,
            'errorType': result.errorType?.toString()
          },
        );
      }

      return result;
    } catch (e, stackTrace) {
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
}
