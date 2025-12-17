import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/logger.dart';

/// Helper class for Firebase Authentication operations.
class FirebaseAuthHelper {
  FirebaseAuthHelper._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Gets a fresh Firebase ID token.
  ///
  /// Forces token refresh to ensure we have a valid, non-expired token.
  /// Returns null if user is not signed in.
  static Future<String?> getFreshFirebaseToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Logger.warning(
          'No Firebase user signed in',
          feature: 'firebase_auth',
          screen: 'firebase_auth_helper',
        );
        return null;
      }

      // Force refresh to get new token
      await user.getIdToken(true);
      final token = await user.getIdToken();

      if (token == null) {
        Logger.error(
          'Failed to get Firebase token',
          feature: 'firebase_auth',
          screen: 'firebase_auth_helper',
        );
        return null;
      }

      return token;
    } catch (e, stackTrace) {
      Logger.error(
        'Error getting Firebase token',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Signs up a new user with Firebase.
  ///
  /// Returns the UserCredential on success, throws FirebaseAuthException on error.
  static Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Hash email for logging (never log raw email addresses)
      final emailHash = _hashEmail(email);
      Logger.info(
        'Creating Firebase user',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
        extra: {'email_hash': emailHash},
      );

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      Logger.info(
        'Firebase user created successfully',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      Logger.error(
        'Firebase sign up error: ${e.code}',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
        error: e,
      );
      rethrow;
    }
  }

  /// Signs in an existing user with Firebase.
  ///
  /// Returns the UserCredential on success, throws FirebaseAuthException on error.
  static Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Hash email for logging (never log raw email addresses)
      final emailHash = _hashEmail(email);
      Logger.info(
        'Signing in Firebase user',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
        extra: {'email_hash': emailHash},
      );

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Logger.info(
        'Firebase sign in successful',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      Logger.error(
        'Firebase sign in error: ${e.code}',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
        error: e,
      );
      rethrow;
    }
  }

  /// Signs out the current Firebase user.
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      Logger.info(
        'Firebase sign out successful',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
      );
    } catch (e, stackTrace) {
      Logger.error(
        'Firebase sign out error',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Gets the current Firebase user.
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Hash email address for logging purposes.
  ///
  /// Uses SHA-256 to create a one-way hash. This allows correlation
  /// of logs without exposing PII.
  static String _hashEmail(String email) {
    final bytes = utf8.encode(email.toLowerCase().trim());
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16); // First 16 chars for readability
  }
}

