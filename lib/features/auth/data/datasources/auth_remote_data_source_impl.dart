import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/firebase_auth_helper.dart';
import '../../domain/models/auth_result.dart';
import '../../domain/models/user.dart';
import 'auth_remote_data_source.dart';

/// Exception thrown when verification rate limit is exceeded.
class VerificationRateLimitException implements Exception {
  final String message;
  final int? remainingAttempts;
  final DateTime? lockoutUntil;

  VerificationRateLimitException({
    required this.message,
    this.remainingAttempts,
    this.lockoutUntil,
  });

  @override
  String toString() => message;
}

/// Exception thrown when resend cooldown is active.
class VerificationCooldownException implements Exception {
  final String message;
  final DateTime? cooldownUntil;
  final int cooldownSeconds;

  VerificationCooldownException({
    required this.message,
    this.cooldownUntil,
    this.cooldownSeconds = 60,
  });

  @override
  String toString() => message;
}

/// Implementation of [AuthRemoteDataSource] using Dio HTTP client.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      Logger.info(
        'Signing in user: $email',
        feature: 'auth',
        screen: 'auth_remote_data_source',
      );

      // Step 1: Sign in with Firebase
      final userCredential =
          await FirebaseAuthHelper.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Step 2: Get Firebase user info
      final user = userCredential.user;
      if (user == null) {
        return AuthResult.failureResult(
          'Failed to get Firebase user',
          AuthErrorType.unknown,
        );
      }

      // Step 3: Return success - backend session creation happens separately via SessionService
      // According to backend spec: Sign-in is Firebase-only, session creation uses POST /api/v1/auth/session
      Logger.info(
        'Firebase sign-in successful',
        feature: 'auth',
        screen: 'auth_remote_data_source',
      );

      // Return AuthResult with user info
      final authUser = User(
        id: user.uid,
        email: user.email ?? email,
        displayName: user.displayName,
        isEmailVerified: user.emailVerified,
      );

      return AuthResult.successResult(authUser);
    } on FirebaseAuthException catch (e) {
      Logger.error(
        'Firebase sign in error: ${e.code}',
        feature: 'auth',
        screen: 'auth_remote_data_source',
        error: e,
      );

      // Map Firebase errors to AuthErrorType
      AuthErrorType errorType;
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          errorType = AuthErrorType.invalidCredentials;
          errorMessage = 'Invalid email or password';
          break;
        case 'user-disabled':
          errorType = AuthErrorType.accountDisabled;
          errorMessage = 'This account has been disabled';
          break;
        case 'too-many-requests':
          errorType = AuthErrorType.tooManyAttempts;
          errorMessage = 'Too many attempts. Please try again later';
          break;
        case 'network-request-failed':
          errorType = AuthErrorType.networkError;
          errorMessage = 'Network error. Please check your connection';
          break;
        case 'operation-not-allowed':
          // Domain restriction error from Firebase Console
          if (e.message?.toLowerCase().contains('allowlisted') == true ||
              e.message?.toLowerCase().contains('domain') == true) {
            errorType = AuthErrorType.unknown;
            errorMessage =
                'This email domain is not allowed. Please contact support or use a different email address.';
          } else {
            errorType = AuthErrorType.unknown;
            errorMessage = e.message ?? 'This operation is not allowed';
          }
          break;
        default:
          // Check if error message contains domain restriction keywords
          if (e.message?.toLowerCase().contains('allowlisted') == true ||
              e.message?.toLowerCase().contains('domain not') == true) {
            errorType = AuthErrorType.unknown;
            errorMessage =
                'This email domain is not allowed. Please contact support or use a different email address.';
          } else {
            errorType = AuthErrorType.unknown;
            errorMessage = e.message ?? 'An error occurred';
          }
      }

      return AuthResult.failureResult(errorMessage, errorType);
    } on DioException catch (e) {
      Logger.error(
        'Backend sign in error',
        feature: 'auth',
        screen: 'auth_remote_data_source',
        error: e,
      );

      return _handleDioError(e);
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected sign in error',
        feature: 'auth',
        screen: 'auth_remote_data_source',
        error: e,
        stackTrace: stackTrace,
      );
      return AuthResult.failureResult(
        'An unexpected error occurred',
        AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<AuthResult> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    UserCredential?
        userCredential; // Declare at top level to access in catch blocks
    try {
      Logger.info(
        'Signing up user: $email',
        feature: 'auth',
        screen: 'auth_remote_data_source',
      );

      // Step 1: Create user in Firebase
      UserCredential? userCredential;
      try {
        userCredential = await FirebaseAuthHelper.signUpWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        // CRITICAL: Backend is the source of truth
        // If Firebase user already exists, check email verification status
        if (e.code == 'email-already-in-use') {
          Logger.warning(
            'Firebase user already exists - checking email verification status',
            feature: 'auth',
            screen: 'auth_remote_data_source',
          );

          try {
            // Try to sign in with existing Firebase user to check verification status
            final existingCredential =
                await FirebaseAuthHelper.signInWithEmailAndPassword(
              email: email,
              password: password,
            );

            // Reload to get latest verification status
            await existingCredential.user?.reload();
            final isVerified = existingCredential.user?.emailVerified ?? false;

            // Sign out immediately - user must verify email first
            await FirebaseAuth.instance.signOut();

            if (isVerified) {
              // Email is verified - user should sign in, not sign up
              return AuthResult.failureResult(
                'This email is already registered and verified. Please sign in instead.',
                AuthErrorType.emailAlreadyRegistered,
              );
            } else {
              // Email not verified - delete Firebase user and allow fresh sign-up
              // This handles case where previous sign-up failed at backend step
              Logger.info(
                'Firebase user exists but email not verified - cleaning up and allowing fresh sign-up',
                feature: 'auth',
                screen: 'auth_remote_data_source',
              );
              try {
                // Sign in again to delete
                final tempCredential =
                    await FirebaseAuthHelper.signInWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                await tempCredential.user?.delete();
                await FirebaseAuth.instance.signOut();

                // Retry sign-up after cleanup
                userCredential =
                    await FirebaseAuthHelper.signUpWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                Logger.info(
                  'Cleaned up unverified Firebase user, retrying sign-up',
                  feature: 'auth',
                  screen: 'auth_remote_data_source',
                );
              } catch (deleteError) {
                Logger.error(
                  'Failed to delete unverified Firebase user: $deleteError',
                  feature: 'auth',
                  screen: 'auth_remote_data_source',
                );
                return AuthResult.failureResult(
                  'An account with this email exists but is not verified. Please check your email for verification link or contact support.',
                  AuthErrorType.emailNotVerified,
                );
              }
            }
          } catch (signInError) {
            // Sign in failed - wrong password or other issue
            await FirebaseAuth.instance.signOut();
            return AuthResult.failureResult(
              'This email is already registered. Please sign in instead.',
              AuthErrorType.emailAlreadyRegistered,
            );
          }
        } else {
          // Other Firebase errors - rethrow to be handled below
          rethrow;
        }
      }

      // If we get here, Firebase user was created successfully (first time)
      // Step 2: Get Firebase ID token
      final idToken = await userCredential?.user?.getIdToken();
      if (idToken == null || userCredential == null) {
        return AuthResult.failureResult(
          'Failed to get Firebase token',
          AuthErrorType.unknown,
        );
      }

      // Step 3: Send token to backend to create user in database
      // Use /api/v1/auth/register endpoint (matches backend)
      Logger.info(
        'Calling backend register endpoint: ${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}',
        feature: 'auth',
        screen: 'auth_remote_data_source',
      );

      // Use longer timeout for sign-up (Render free tier services sleep and take 30-60s to wake up)
      final response = await _apiClient.dio.post(
        ApiConfig.registerEndpoint, // POST /api/v1/auth/register
        data: {
          'id_token': idToken,
        },
        options: Options(
          sendTimeout:
              const Duration(seconds: 90), // 90 seconds for backend to wake up
          receiveTimeout: const Duration(seconds: 90),
        ),
      );

      Logger.info(
        'Backend register response: ${response.statusCode}',
        feature: 'auth',
        screen: 'auth_remote_data_source',
        extra: {
          'status_code': response.statusCode,
          'response_data': response.data.toString(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        // Store Firebase token for future API calls
        await _apiClient.setTokens(
          accessToken: idToken,
          refreshToken: null, // Firebase handles refresh
        );

        // Extract user data - handle different response formats
        Map<String, dynamic>? userData;
        if (data is Map) {
          // Try different possible field names
          if (data['user'] is Map) {
            userData = Map<String, dynamic>.from(data['user'] as Map);
          } else if (data['data'] is Map) {
            userData = Map<String, dynamic>.from(data['data'] as Map);
          } else if (data.containsKey('id') || data.containsKey('email')) {
            userData = Map<String, dynamic>.from(data);
          }
        }

        if (userData != null) {
          final user = User(
            id: userData['id']?.toString() ??
                userData['user_id']?.toString() ??
                userCredential.user?.uid ??
                '',
            email: userData['email'] ?? email,
            displayName: userData['displayName'] ??
                userData['full_name'] ??
                userData['name'] ??
                displayName,
            isEmailVerified: userData['isEmailVerified'] ??
                userData['email_verified'] ??
                userCredential.user?.emailVerified ??
                false,
            createdAt: userData['created_at'] != null
                ? DateTime.tryParse(userData['created_at']) ?? DateTime.now()
                : (userData['createdAt'] != null
                    ? DateTime.tryParse(userData['createdAt']) ?? DateTime.now()
                    : DateTime.now()),
          );

          Logger.info(
            'Sign-up successful - user created',
            feature: 'auth',
            screen: 'auth_remote_data_source',
            extra: {'user_id': user.id, 'email': user.email},
          );

          return AuthResult.successResult(user);
        }

        // If no user data but status is 200/201, assume success and create user from Firebase
        Logger.info(
          'Backend returned success but no user data - using Firebase user',
          feature: 'auth',
          screen: 'auth_remote_data_source',
          extra: {'response_data': data},
        );

        final firebaseUser = userCredential.user;
        if (firebaseUser != null) {
          final user = User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? email,
            displayName: displayName,
            isEmailVerified: firebaseUser.emailVerified,
            createdAt: DateTime.now(),
          );

          return AuthResult.successResult(user);
        }

        // Log invalid response format
        Logger.error(
          'Invalid response format - missing user data and Firebase user',
          feature: 'auth',
          screen: 'auth_remote_data_source',
          extra: {'response_data': data},
        );

        return AuthResult.failureResult(
          'Invalid response from server. Please try again.',
          AuthErrorType.unknown,
        );
      } else {
        // Log unexpected status code
        Logger.error(
          'Unexpected status code: ${response.statusCode}',
          feature: 'auth',
          screen: 'auth_remote_data_source',
          extra: {'response_data': response.data},
        );

        // Try to extract error message from response
        String errorMsg = 'Sign up failed';
        if (response.data is Map) {
          final data = response.data as Map;
          errorMsg = data['error']?['message'] as String? ??
              data['message'] as String? ??
              data['detail'] as String? ??
              'Sign up failed: ${response.statusCode}';
        }

        // Backend registration failed - delete Firebase user to allow retry
        Logger.warning(
          'Backend registration failed after Firebase user creation - cleaning up Firebase user',
          feature: 'auth',
          screen: 'auth_remote_data_source',
          extra: {'status_code': response.statusCode, 'error': errorMsg},
        );

        // Delete Firebase user to allow clean retry
        try {
          await userCredential?.user?.delete();
          Logger.info(
            'Firebase user deleted successfully after backend registration failure',
            feature: 'auth',
            screen: 'auth_remote_data_source',
          );
        } catch (deleteError) {
          Logger.warning(
            'Failed to delete Firebase user after backend registration failure: $deleteError',
            feature: 'auth',
            screen: 'auth_remote_data_source',
          );
          // Continue anyway - user can try again and we'll handle it above
        }

        return AuthResult.failureResult(
          errorMsg,
          AuthErrorType.unknown,
        );
      }
    } on DioException catch (e) {
      // Handle network/backend errors during backend registration
      Logger.error(
        'Backend registration error: ${e.type} - ${e.message}',
        feature: 'auth',
        screen: 'auth_remote_data_source',
        error: e,
      );

      // If Firebase user was created, delete it to allow retry
      if (userCredential != null) {
        Logger.warning(
          'Backend registration failed (network/error) - cleaning up Firebase user',
          feature: 'auth',
          screen: 'auth_remote_data_source',
        );
        try {
          await userCredential.user?.delete();
          Logger.info(
            'Firebase user deleted successfully after backend registration failure',
            feature: 'auth',
            screen: 'auth_remote_data_source',
          );
        } catch (deleteError) {
          Logger.warning(
            'Failed to delete Firebase user after backend registration failure: $deleteError',
            feature: 'auth',
            screen: 'auth_remote_data_source',
          );
        }
      }

      // Map DioException to appropriate error
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return AuthResult.failureResult(
          'Network error. Please check your connection and try again.',
          AuthErrorType.networkError,
        );
      }

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        if (statusCode == 500) {
          return AuthResult.failureResult(
            'Backend server error. Please try again later.',
            AuthErrorType.unknown,
          );
        }
      }

      return AuthResult.failureResult(
        'Failed to connect to server. Please try again.',
        AuthErrorType.networkError,
      );
    } on FirebaseAuthException catch (e) {
      Logger.error(
        'Firebase sign up error: ${e.code}',
        feature: 'auth',
        screen: 'auth_remote_data_source',
      );

      // Map Firebase errors to AuthErrorType
      AuthErrorType errorType;
      String errorMessage;

      switch (e.code) {
        case 'email-already-in-use':
          errorType = AuthErrorType.emailAlreadyRegistered;
          errorMessage = 'Email already registered';
          break;
        case 'weak-password':
          errorType = AuthErrorType.invalidCredentials;
          errorMessage = 'Password is too weak';
          break;
        case 'invalid-email':
          errorType = AuthErrorType.invalidCredentials;
          errorMessage = 'Invalid email address';
          break;
        case 'network-request-failed':
          errorType = AuthErrorType.networkError;
          errorMessage = 'Network error. Please check your connection';
          break;
        case 'operation-not-allowed':
          // Domain restriction error from Firebase Console
          if (e.message?.toLowerCase().contains('allowlisted') == true ||
              e.message?.toLowerCase().contains('domain') == true) {
            errorType = AuthErrorType.unknown;
            errorMessage =
                'This email domain is not allowed. Please contact support or use a different email address.';
          } else {
            errorType = AuthErrorType.unknown;
            errorMessage = e.message ?? 'This operation is not allowed';
          }
          break;
        default:
          // Check if error message contains domain restriction keywords
          if (e.message?.toLowerCase().contains('allowlisted') == true ||
              e.message?.toLowerCase().contains('domain not') == true) {
            errorType = AuthErrorType.unknown;
            errorMessage =
                'This email domain is not allowed. Please contact support or use a different email address.';
          } else {
            errorType = AuthErrorType.unknown;
            errorMessage = e.message ?? 'An error occurred';
          }
      }

      return AuthResult.failureResult(errorMessage, errorType);
    } on DioException catch (e) {
      Logger.error(
        'Backend sign up error: ${e.type} - ${e.message}',
        feature: 'auth',
        screen: 'auth_remote_data_source',
        error: e,
      );

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        Logger.error(
          'Backend sign-up error response',
          feature: 'auth',
          screen: 'auth_remote_data_source',
          error: e,
          extra: {
            'status_code': statusCode,
            'response_data': responseData.toString(),
          },
        );

        // Handle 500 Internal Server Error
        if (statusCode == 500) {
          String errorMsg =
              'Backend server error. The server is experiencing issues. Please try again later or contact support.';
          if (responseData is Map) {
            final backendMsg = responseData['error']?['message'] as String?;
            if (backendMsg != null &&
                !backendMsg.toLowerCase().contains('internal server error')) {
              errorMsg = backendMsg;
            }
          }
          return AuthResult.failureResult(
            errorMsg,
            AuthErrorType.unknown,
          );
        }

        // Try to extract error message from response
        String? errorMsg;
        if (responseData is Map) {
          errorMsg = responseData['error']?['message'] as String? ??
              responseData['message'] as String? ??
              responseData['detail'] as String?;
        }

        if (errorMsg != null) {
          Logger.error(
            'Backend error message: $errorMsg',
            feature: 'auth',
            screen: 'auth_remote_data_source',
          );
          return AuthResult.failureResult(
            errorMsg,
            AuthErrorType.unknown,
          );
        }
      }

      return _handleDioError(e);
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected sign up error: $e',
        feature: 'auth',
        screen: 'auth_remote_data_source',
        error: e,
        stackTrace: stackTrace,
      );

      // Provide more specific error message
      String errorMsg = 'An unexpected error occurred';
      if (e.toString().contains('FormatException') ||
          e.toString().contains('type')) {
        errorMsg = 'Server returned invalid data format. Please try again.';
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        errorMsg =
            'Cannot connect to server. Please check your internet connection.';
      } else {
        errorMsg = 'An error occurred: ${e.toString()}';
      }

      return AuthResult.failureResult(
        errorMsg,
        AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Sign out from Firebase
      await FirebaseAuthHelper.signOut();

      // Clear stored tokens
      await _apiClient.clearTokens();

      Logger.info(
        'Sign out successful',
        feature: 'auth',
        screen: 'auth_remote_data_source',
      );
    } catch (e) {
      Logger.error(
        'Sign out error (continuing anyway)',
        feature: 'auth',
        screen: 'auth_remote_data_source',
        error: e,
      );
      // Still clear tokens even if Firebase sign out fails
      await _apiClient.clearTokens();
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      // Get fresh Firebase token
      final token = await FirebaseAuthHelper.getFreshFirebaseToken();
      if (token == null) {
        return null;
      }

      final response = await _apiClient.dio.get(
        ApiConfig.getCurrentUserEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final userData = data['user'] as Map<String, dynamic>?;

        if (userData != null) {
          return User(
            id: userData['id']?.toString() ?? '',
            email: userData['email'] ?? '',
            displayName: userData['displayName'] ?? userData['full_name'],
            isEmailVerified: userData['isEmailVerified'] ?? false,
            createdAt: userData['created_at'] != null
                ? DateTime.parse(userData['created_at'])
                : null,
          );
        }
      }
      return null;
    } catch (e) {
      Logger.error(
        'Get current user error',
        feature: 'auth',
        screen: 'auth_remote_data_source',
        error: e,
      );
      return null;
    }
  }

  @override
  Future<bool> sendPasswordResetEmail(String email) async {
    // Firebase handles password reset via email links - no backend call needed
    try {
      await FirebaseAuthHelper.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      Logger.error(
        'Send password reset email error',
        feature: 'auth',
        screen: 'auth_remote_data_source',
        error: e,
      );
      return false;
    }
  }

  // Old verification code methods removed - Firebase handles email verification via links
  // No backend endpoints needed for email verification

  // Removed: verifyEmailCode - Firebase handles email verification
  // Removed: resendVerificationCode - Firebase handles email verification
  // Removed: verifyPasswordResetCode - Firebase handles password reset via links
  // Removed: resetPassword (backend version) - Firebase handles password reset

  // Note: sendPasswordResetEmail now uses Firebase (not backend)

  // These methods are no longer implemented - Firebase handles everything
  @override
  Future<bool> verifyEmailCode(String code, String email) async {
    throw UnimplementedError(
        'Email verification is handled by Firebase via email links');
  }

  @override
  Future<bool> resendVerificationCode(String email) async {
    throw UnimplementedError(
        'Email verification is handled by Firebase via email links');
  }

  @override
  Future<bool> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    throw UnimplementedError(
        'Password reset is handled by Firebase via email links');
  }

  @override
  Future<bool> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    throw UnimplementedError(
        'Password reset is handled by Firebase via email links');
  }

  /// Handles Dio errors and maps them to AuthErrorType.
  AuthResult _handleDioError(DioException e) {
    // Network errors
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return AuthResult.failureResult(
        'Network error. Please check your connection',
        AuthErrorType.networkError,
      );
    }

    // HTTP errors
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final errorData = e.response!.data;
      final errorType = errorData['error']?['type'] as String?;
      final errorMessage = errorData['error']?['message'] as String? ??
          errorData['message'] as String? ??
          'An error occurred';

      // Map error types
      switch (errorType) {
        case 'INVALID_CREDENTIALS':
          return AuthResult.failureResult(
            errorMessage,
            AuthErrorType.invalidCredentials,
          );
        case 'EMAIL_NOT_VERIFIED':
          return AuthResult.failureResult(
            errorMessage,
            AuthErrorType.emailNotVerified,
          );
        case 'TOO_MANY_ATTEMPTS':
          return AuthResult.failureResult(
            errorMessage,
            AuthErrorType.tooManyAttempts,
          );
        case 'EMAIL_ALREADY_EXISTS':
          return AuthResult.failureResult(
            errorMessage,
            AuthErrorType.invalidCredentials,
          );
        default:
          // Fallback to status code mapping
          if (statusCode == 401) {
            return AuthResult.failureResult(
              errorMessage,
              AuthErrorType.invalidCredentials,
            );
          } else if (statusCode == 403) {
            return AuthResult.failureResult(
              errorMessage,
              AuthErrorType.emailNotVerified,
            );
          } else if (statusCode == 429) {
            return AuthResult.failureResult(
              errorMessage,
              AuthErrorType.tooManyAttempts,
            );
          }
      }

      return AuthResult.failureResult(
        errorMessage,
        AuthErrorType.unknown,
      );
    }

    // Unknown error
    return AuthResult.failureResult(
      e.message ?? 'An unexpected error occurred',
      AuthErrorType.unknown,
    );
  }

  @override
  Future<bool> sendDeleteAccountCode(String email) async {
    // Backend doesn't have send-delete-code endpoint
    // Account deletion is a single-step process via DELETE /api/v1/user/profile
    // This method is kept for compatibility but always returns true
    Logger.info(
      'sendDeleteAccountCode called for: $email (backend uses single-step deletion)',
      feature: 'auth',
      screen: 'auth_remote_data_source',
    );
    return true;
  }

  @override
  Future<bool> deleteAccount({
    required String email,
    required String code,
  }) async {
    try {
      Logger.info(
        'Deleting account (soft delete)',
        feature: 'auth',
        screen: 'auth_remote_data_source',
      );

      // Backend expects: DELETE /api/v1/user/profile
      // Firebase token is automatically added by ApiClient interceptor
      // No email or code needed - backend uses Firebase token from Authorization header
      final response = await _apiClient.dio.delete(
        ApiConfig.deleteAccountEndpoint,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        Logger.info(
          'Account deleted successfully',
          feature: 'auth',
          screen: 'auth_remote_data_source',
        );
        return true;
      }

      Logger.warning(
        'Delete account returned status: ${response.statusCode}',
        feature: 'auth',
        screen: 'auth_remote_data_source',
      );
      return false;
    } on DioException catch (e) {
      Logger.error(
        'Delete account error',
        feature: 'auth',
        screen: 'auth_remote_data_source',
        error: e,
      );

      // Handle rate limiting (429)
      if (e.response?.statusCode == 429) {
        final errorData = e.response?.data;
        final lockoutUntil = errorData?['lockout_until'] as String?;
        final remainingAttempts = errorData?['remaining_attempts'] as int?;

        throw VerificationRateLimitException(
          message: errorData?['error']?['message'] ??
              errorData?['message'] ??
              'Too many attempts. Please try again later.',
          lockoutUntil:
              lockoutUntil != null ? DateTime.tryParse(lockoutUntil) : null,
          remainingAttempts: remainingAttempts,
        );
      }

      return false;
    } catch (e) {
      if (e is VerificationRateLimitException) rethrow;
      Logger.error(
        'Unexpected error deleting account',
        feature: 'auth',
        screen: 'auth_remote_data_source',
        error: e,
      );
      return false;
    }
  }
}
