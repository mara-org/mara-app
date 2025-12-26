import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../utils/logger.dart';
import 'email_rate_limiter.dart';
import '../exceptions/rate_limit_exception.dart';

/// Helper class for Firebase Authentication operations.
class FirebaseAuthHelper {
  FirebaseAuthHelper._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Ensures Firebase is initialized before use.
  static Future<void> _ensureInitialized() async {
    try {
      if (Firebase.apps.isEmpty) {
        Logger.warning(
          '⚠️ Firebase not initialized, attempting to initialize...',
          feature: 'firebase_auth',
          screen: 'firebase_auth_helper',
        );
        await Firebase.initializeApp();

        // Verify initialization succeeded
        if (Firebase.apps.isEmpty) {
          throw Exception(
              'Firebase.initializeApp() completed but no apps found');
        }

        Logger.info(
          '✅ Firebase initialized successfully in helper (${Firebase.apps.length} app(s))',
          feature: 'firebase_auth',
          screen: 'firebase_auth_helper',
        );
      } else {
        Logger.info(
          '✅ Firebase already initialized (${Firebase.apps.length} app(s))',
          feature: 'firebase_auth',
          screen: 'firebase_auth_helper',
        );
      }
    } catch (e, stackTrace) {
      Logger.error(
        '❌ Failed to initialize Firebase: $e',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
        error: e,
        stackTrace: stackTrace,
      );
      // Re-throw with a user-friendly message
      throw Exception(
          'Firebase initialization failed. Please restart the app. Error: $e');
    }
  }

  /// Gets a fresh Firebase ID token.
  ///
  /// Forces token refresh to ensure we have a valid, non-expired token.
  /// Returns null if user is not signed in.
  static Future<String?> getFreshFirebaseToken() async {
    // Ensure Firebase is initialized
    await _ensureInitialized();

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
    // Ensure Firebase is initialized
    await _ensureInitialized();

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
    // Ensure Firebase is initialized
    await _ensureInitialized();

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

  /// Signs in with Apple.
  ///
  /// Returns the UserCredential on success, throws exception on error.
  /// Works for both new users (sign-up) and existing users (sign-in).
  static Future<UserCredential> signInWithApple() async {
    // Ensure Firebase is initialized
    await _ensureInitialized();

    // Check if running on iOS
    if (!Platform.isIOS) {
      throw Exception('Sign in with Apple is only available on iOS');
    }

    try {
      Logger.info(
        'Starting Sign in with Apple',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
      );

      // Step 1: Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      Logger.info(
        'Apple credential received',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
      );

      // Step 2: Create OAuth credential for Firebase
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Step 3: Sign in to Firebase with Apple credential
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Step 4: If this is a new user and we got name info, update the display name
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        final displayName = appleCredential.givenName != null &&
                appleCredential.familyName != null
            ? '${appleCredential.givenName} ${appleCredential.familyName}'
            : appleCredential.givenName ?? appleCredential.familyName;

        if (displayName != null && userCredential.user != null) {
          await userCredential.user!.updateDisplayName(displayName);
          await userCredential.user!.reload();
        }
      }

      Logger.info(
        'Sign in with Apple successful',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
        extra: {
          'is_new_user': userCredential.additionalUserInfo?.isNewUser ?? false,
        },
      );

      return userCredential;
    } on SignInWithAppleAuthorizationException catch (e) {
      Logger.error(
        'Apple sign-in authorization error: ${e.code}',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
        error: e,
      );

      // Handle specific Apple sign-in errors
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          throw Exception('Sign in with Apple was canceled');
        case AuthorizationErrorCode.failed:
          throw Exception('Sign in with Apple failed. Please try again.');
        case AuthorizationErrorCode.invalidResponse:
          throw Exception('Invalid response from Apple. Please try again.');
        case AuthorizationErrorCode.notHandled:
          throw Exception('Sign in with Apple not handled. Please try again.');
        case AuthorizationErrorCode.unknown:
          throw Exception(
              'Unknown error during Apple sign-in. Please try again.');
        default:
          throw Exception('Sign in with Apple failed: ${e.message ?? e.code}');
      }
    } on FirebaseAuthException catch (e) {
      Logger.error(
        'Firebase Apple sign-in error: ${e.code}',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
        error: e,
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected error during Apple sign-in',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Sign in with Apple failed: ${e.toString()}');
    }
  }

  /// Signs out the current Firebase user.
  static Future<void> signOut() async {
    // Ensure Firebase is initialized
    await _ensureInitialized();

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
    // Check if Firebase is initialized
    try {
      if (Firebase.apps.isEmpty) {
        Logger.warning(
          'Firebase not initialized when getting current user',
          feature: 'firebase_auth',
          screen: 'firebase_auth_helper',
        );
        return null;
      }
      return _auth.currentUser;
    } catch (e) {
      Logger.error(
        'Error getting current user: $e',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
        error: e,
      );
      return null;
    }
  }

  /// Sends email verification link to current user.
  ///
  /// Returns true on success, throws FirebaseAuthException on error.
  /// Throws RateLimitException if rate limit exceeded (5 requests per hour).
  static Future<bool> sendEmailVerification() async {
    await _ensureInitialized();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        Logger.warning(
          'No user signed in, cannot send verification email',
          feature: 'firebase_auth',
          screen: 'firebase_auth_helper',
        );
        return false;
      }

      final email = user.email ?? 'unknown';

      // Check rate limit (5 requests per hour)
      if (!EmailRateLimiter.canMakeRequest(email)) {
        final minutesUntilNext =
            EmailRateLimiter.getMinutesUntilNextRequest(email);
        throw RateLimitException(
          'Too many verification email requests. Please wait $minutesUntilNext minute${minutesUntilNext != 1 ? 's' : ''} before requesting again.',
          minutesUntilNext: minutesUntilNext,
        );
      }

      // Hash email for logging
      final emailHash = _hashEmail(email);
      Logger.info(
        'Sending email verification link',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
        extra: {'email_hash': emailHash},
      );

      // Send email verification with deep link configuration
      // Note: Link expiration (2 minutes) must be set in Firebase Console
      // Firebase Console → Authentication → Settings → Action code settings
      await user.sendEmailVerification(
        ActionCodeSettings(
          url: 'com.iammara.maraApp://verify-email',
          handleCodeInApp: true,
          androidPackageName: null,
          iOSBundleId: 'com.iammara.maraApp',
        ),
      );

      // Record successful request for rate limiting
      EmailRateLimiter.recordRequest(email);

      Logger.info(
        'Email verification link sent successfully',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
      );

      return true;
    } on FirebaseAuthException catch (e) {
      Logger.error(
        'Firebase send email verification error: ${e.code}',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
        error: e,
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected error sending email verification',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Checks if current user's email is verified.
  ///
  /// Reloads user data before checking to ensure status is up-to-date.
  static Future<bool> isEmailVerified() async {
    await _ensureInitialized();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }

      // Reload user to get latest verification status
      await user.reload();
      final refreshedUser = _auth.currentUser;

      return refreshedUser?.emailVerified ?? false;
    } catch (e, stackTrace) {
      Logger.error(
        'Error checking email verification status',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Sends password reset email to the specified email address.
  ///
  /// Returns true on success, throws FirebaseAuthException on error.
  /// Throws RateLimitException if rate limit exceeded (5 requests per hour).
  static Future<bool> sendPasswordResetEmail(String email) async {
    await _ensureInitialized();

    try {
      // Check rate limit (5 requests per hour)
      if (!EmailRateLimiter.canMakeRequest(email)) {
        final minutesUntilNext =
            EmailRateLimiter.getMinutesUntilNextRequest(email);
        throw RateLimitException(
          'Too many password reset requests. Please wait $minutesUntilNext minute${minutesUntilNext != 1 ? 's' : ''} before requesting again.',
          minutesUntilNext: minutesUntilNext,
        );
      }

      // Hash email for logging
      final emailHash = _hashEmail(email);
      Logger.info(
        'Sending password reset email',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
        extra: {'email_hash': emailHash},
      );

      // Send password reset email with deep link configuration
      // Note: Link expiration (10 minutes) must be set in Firebase Console
      // Firebase Console → Authentication → Settings → Action code settings
      await _auth.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: ActionCodeSettings(
          url: 'com.iammara.maraApp://reset-password',
          handleCodeInApp: true,
          androidPackageName: null,
          iOSBundleId: 'com.iammara.maraApp',
        ),
      );

      // Record successful request for rate limiting
      EmailRateLimiter.recordRequest(email);

      Logger.info(
        'Password reset email sent successfully',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
      );

      return true;
    } on FirebaseAuthException catch (e) {
      Logger.error(
        'Firebase send password reset email error: ${e.code}',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
        error: e,
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected error sending password reset email',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Confirms password reset with the provided action code and new password.
  ///
  /// [oobCode] - The out-of-band code from the password reset email link.
  /// [newPassword] - The new password to set.
  ///
  /// Returns true on success, throws FirebaseAuthException on error.
  static Future<bool> confirmPasswordReset({
    required String oobCode,
    required String newPassword,
  }) async {
    await _ensureInitialized();

    try {
      Logger.info(
        'Confirming password reset',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
      );

      await _auth.confirmPasswordReset(
        code: oobCode,
        newPassword: newPassword,
      );

      Logger.info(
        'Password reset confirmed successfully',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
      );

      return true;
    } on FirebaseAuthException catch (e) {
      Logger.error(
        'Firebase confirm password reset error: ${e.code}',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
        error: e,
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected error confirming password reset',
        feature: 'firebase_auth',
        screen: 'firebase_auth_helper',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Stream of auth state changes, useful for detecting email verification.
  ///
  /// Returns a stream that emits User objects when auth state changes.
  static Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
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
