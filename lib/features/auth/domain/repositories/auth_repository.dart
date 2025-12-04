import '../models/auth_result.dart';
import '../models/user.dart';

/// Repository interface for authentication operations.
///
/// This is a domain layer interface that defines the contract
/// for authentication operations. Implementations live in the data layer.
abstract class AuthRepository {
  /// Signs in a user with email and password.
  Future<AuthResult> signIn({
    required String email,
    required String password,
  });

  /// Signs up a new user.
  Future<AuthResult> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  /// Signs out the current user.
  Future<void> signOut();

  /// Gets the current authenticated user.
  Future<User?> getCurrentUser();

  /// Sends a password reset email.
  Future<bool> sendPasswordResetEmail(String email);

  /// Verifies an email verification code.
  Future<bool> verifyEmailCode(String code);

  /// Resends email verification code.
  Future<bool> resendVerificationCode();
}

