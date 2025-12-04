import '../../domain/models/user.dart';
import '../../../../core/storage/local_cache.dart';

/// Local data source for authentication operations.
///
/// Handles local storage of user data, tokens, etc.
class AuthLocalDataSource {
  static const String _userKey = 'auth_user';
  static const String _tokenKey = 'auth_token';

  /// Constructor for [AuthLocalDataSource].
  ///
  /// The [LocalCache] parameter is kept for future use when we might
  /// need instance-based caching. For now, we use static methods.
  AuthLocalDataSource(LocalCache localCache);

  /// Saves user to local storage.
  Future<void> saveUser(User user) async {
    // In a real implementation, serialize user to JSON
    // For now, store email as a simple example
    await LocalCache.saveString(_userKey, user.email);
  }

  /// Gets user from local storage.
  Future<User?> getUser() async {
    final email = LocalCache.getString(_userKey);
    if (email == null || email.isEmpty) {
      return null;
    }

    // In a real implementation, deserialize from JSON
    // For now, create a placeholder user
    return User(
      id: 'local-user-id',
      email: email,
      isEmailVerified: false,
    );
  }

  /// Clears user data from local storage.
  Future<void> clearUser() async {
    await LocalCache.remove(_userKey);
    await LocalCache.remove(_tokenKey);
  }

  /// Saves authentication token.
  Future<void> saveToken(String token) async {
    await LocalCache.saveString(_tokenKey, token);
  }

  /// Gets authentication token.
  String? getToken() {
    return LocalCache.getString(_tokenKey);
  }
}
