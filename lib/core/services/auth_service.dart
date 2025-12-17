import 'package:firebase_auth/firebase_auth.dart';

/// Authentication service for Firebase operations.
///
/// Provides methods to get Firebase ID tokens and check authentication status.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get Firebase ID token.
  ///
  /// Forces token refresh to ensure we have a valid, non-expired token.
  /// Returns null if user is not signed in.
  Future<String?> getFirebaseIdToken() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Force refresh if token expired
      return await user.getIdToken(true);
    }
    return null;
  }

  /// Check if user is authenticated.
  bool get isAuthenticated => _auth.currentUser != null;

  /// Get current user ID.
  String? get userId => _auth.currentUser?.uid;

  /// Get current Firebase user.
  User? get currentUser => _auth.currentUser;
}

