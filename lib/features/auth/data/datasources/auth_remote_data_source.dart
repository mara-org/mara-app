import '../../domain/models/auth_result.dart';
import '../../domain/models/user.dart';

/// Remote data source for authentication operations.
///
/// This interface defines the contract for remote authentication APIs.
/// Implementation will call actual backend endpoints when available.
abstract class AuthRemoteDataSource {
  /// Signs in a user via remote API.
  Future<AuthResult> signIn({
    required String email,
    required String password,
  });

  /// Signs up a new user via remote API.
  Future<AuthResult> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  /// Signs out the current user via remote API.
  Future<void> signOut();

  /// Gets the current authenticated user from remote API.
  Future<User?> getCurrentUser();

  /// Sends a password reset email via Firebase (not backend).
  /// Note: Firebase handles password reset via email links.
  Future<bool> sendPasswordResetEmail(String email);

  /// Sends delete account verification code via remote API.
  Future<bool> sendDeleteAccountCode(String email);

  /// Deletes account permanently via remote API.
  Future<bool> deleteAccount({
    required String email,
    required String code,
  });
}
