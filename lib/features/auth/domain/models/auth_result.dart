import 'user.dart';

/// Result of an authentication operation.
///
/// This domain model represents the outcome of authentication attempts.
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? errorMessage;
  final AuthErrorType? errorType;

  const AuthResult.success(this.user)
      : isSuccess = true,
        errorMessage = null,
        errorType = null;

  const AuthResult.failure(this.errorMessage, this.errorType)
      : isSuccess = false,
        user = null;

  /// Creates a success result.
  factory AuthResult.successResult(User user) => AuthResult.success(user);

  /// Creates a failure result with a specific error type.
  factory AuthResult.failureResult(String message, AuthErrorType type) =>
      AuthResult.failure(message, type);

  @override
  String toString() => isSuccess
      ? 'AuthResult.success(user: $user)'
      : 'AuthResult.failure(error: $errorMessage, type: $errorType)';
}

/// Types of authentication errors.
enum AuthErrorType {
  /// Invalid credentials (wrong email/password).
  invalidCredentials,

  /// Network error (connection failed, timeout, etc.).
  networkError,

  /// Email not verified.
  emailNotVerified,

  /// Account disabled or locked.
  accountDisabled,

  /// Too many attempts.
  tooManyAttempts,

  /// Unknown or unexpected error.
  unknown,
}

