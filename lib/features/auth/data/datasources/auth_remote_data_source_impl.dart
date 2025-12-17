import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/firebase_auth_helper.dart';
import '../../domain/models/auth_result.dart';
import '../../domain/models/user.dart';
import '../../domain/models/verification_result.dart';
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
      final userCredential = await FirebaseAuthHelper.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Step 2: Get Firebase ID token
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        return AuthResult.failureResult(
          'Failed to get Firebase token',
          AuthErrorType.unknown,
        );
      }

      // Step 3: Send token to backend
      final response = await _apiClient.dio.post(
        ApiConfig.loginEndpoint,
        data: {
          'id_token': idToken,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Store Firebase token for future API calls
        await _apiClient.setTokens(
          accessToken: idToken,
          refreshToken: null, // Firebase handles refresh
        );

        // Extract user data
        final userData = data['user'] as Map<String, dynamic>?;
        if (userData != null) {
          final user = User(
            id: userData['id']?.toString() ?? '',
            email: userData['email'] ?? email,
            displayName: userData['displayName'] ?? userData['full_name'],
            isEmailVerified: userData['isEmailVerified'] ?? 
                userCredential.user?.emailVerified ?? false,
            createdAt: userData['created_at'] != null
                ? DateTime.parse(userData['created_at'])
                : null,
          );

          return AuthResult.successResult(user);
        }

        return AuthResult.failureResult(
          'Invalid response format',
          AuthErrorType.unknown,
        );
      } else {
        return AuthResult.failureResult(
          'Sign in failed: ${response.statusCode}',
          AuthErrorType.unknown,
        );
      }
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
        default:
          errorType = AuthErrorType.unknown;
          errorMessage = e.message ?? 'An error occurred';
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
    try {
      Logger.info(
        'Signing up user: $email',
        feature: 'auth',
        screen: 'auth_remote_data_source',
      );

      // Step 1: Create user in Firebase
      final userCredential = await FirebaseAuthHelper.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Step 2: Get Firebase ID token
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        return AuthResult.failureResult(
          'Failed to get Firebase token',
          AuthErrorType.unknown,
        );
      }

      // Step 3: Send token to backend to create user in database
      final response = await _apiClient.dio.post(
        ApiConfig.registerEndpoint,
        data: {
          'id_token': idToken,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        // Store Firebase token for future API calls
        await _apiClient.setTokens(
          accessToken: idToken,
          refreshToken: null, // Firebase handles refresh
        );

        // Extract user data
        final userData = data['user'] as Map<String, dynamic>?;
        if (userData != null) {
          final user = User(
            id: userData['id']?.toString() ?? '',
            email: userData['email'] ?? email,
            displayName: userData['displayName'] ?? userData['full_name'] ?? displayName,
            isEmailVerified: userData['isEmailVerified'] ?? 
                userCredential.user?.emailVerified ?? false,
            createdAt: userData['created_at'] != null
                ? DateTime.parse(userData['created_at'])
                : DateTime.now(),
          );

          return AuthResult.successResult(user);
        }

        return AuthResult.failureResult(
          'Invalid response format',
          AuthErrorType.unknown,
        );
      } else {
        return AuthResult.failureResult(
          'Sign up failed: ${response.statusCode}',
          AuthErrorType.unknown,
        );
      }
    } on FirebaseAuthException catch (e) {
      Logger.error(
        'Firebase sign up error: ${e.code}',
        feature: 'auth',
        screen: 'auth_remote_data_source',
        error: e,
      );

      // Map Firebase errors to AuthErrorType
      AuthErrorType errorType;
      String errorMessage;

      switch (e.code) {
        case 'email-already-in-use':
          errorType = AuthErrorType.invalidCredentials;
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
        default:
          errorType = AuthErrorType.unknown;
          errorMessage = e.message ?? 'An error occurred';
      }

      return AuthResult.failureResult(errorMessage, errorType);
    } on DioException catch (e) {
      Logger.error(
        'Backend sign up error',
        feature: 'auth',
        screen: 'auth_remote_data_source',
        error: e,
      );

      return _handleDioError(e);
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected sign up error',
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
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.forgotPasswordEndpoint,
        data: {'email': email},
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        return data['success'] == true;
      }
      return false;
    } on DioException catch (e) {
      Logger.error(
        'Send password reset email error',
        feature: 'auth',
        screen: 'auth_remote_data_source',
        error: e,
      );
      
      // Handle rate limiting (429) - unified response (doesn't reveal if email exists)
      if (e.response?.statusCode == 429) {
        final errorData = e.response?.data;
        final cooldownUntil = errorData?['cooldown_until'] as String?;
        final cooldownSeconds = errorData?['cooldown_seconds'] as int?;
        
        throw VerificationCooldownException(
          message: errorData?['error']?['message'] ?? 
                   errorData?['message'] ?? 
                   'Please wait before requesting another code.',
          cooldownUntil: cooldownUntil != null 
              ? DateTime.tryParse(cooldownUntil) 
              : null,
          cooldownSeconds: cooldownSeconds ?? 60,
        );
      }
      
      // Return false for other errors (unified response - doesn't reveal if email exists)
      return false;
    } catch (e) {
      if (e is VerificationCooldownException) rethrow;
      Logger.error(
        'Unexpected error sending password reset email',
        feature: 'auth',
        screen: 'auth_remote_data_source',
        error: e,
      );
      // Return false (unified response - doesn't reveal if email exists)
      return false;
    }
  }

  @override
  Future<bool> verifyEmailCode(String code, String email) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.verifyEmailEndpoint,
        data: {
          'email': email,
          'code': code,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['user'] != null) {
          // Update stored token if provided
          final token = data['token'] as String?;
          final refreshToken = data['refreshToken'] as String?;
          if (token != null) {
            await _apiClient.setTokens(
              accessToken: token,
              refreshToken: refreshToken,
            );
          }
          return true;
        }
      }
      return false;
    } on DioException catch (e) {
      Logger.error(
        'Verify email code error',
        feature: 'auth',
        screen: 'auth_remote_data_source',
        error: e,
      );
      
      // Handle rate limiting (429)
      if (e.response?.statusCode == 429) {
        final errorData = e.response?.data;
        final lockoutUntil = errorData?['lockout_until'] as String?;
        final remainingAttempts = errorData?['remaining_attempts'] as int?;
        
        // Throw a specific exception with rate limit info
        throw VerificationRateLimitException(
          message: errorData?['error']?['message'] ?? 
                   errorData?['message'] ?? 
                   'Too many attempts. Please try again later.',
          remainingAttempts: remainingAttempts,
          lockoutUntil: lockoutUntil != null 
              ? DateTime.tryParse(lockoutUntil) 
              : null,
        );
      }
      
      return false;
    } catch (e) {
      if (e is VerificationRateLimitException) rethrow;
      Logger.error(
        'Unexpected error verifying email code',
        feature: 'auth',
        screen: 'auth_remote_data_source',
        error: e,
      );
      return false;
    }
  }

  @override
  Future<bool> resendVerificationCode(String email) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.resendVerificationEndpoint,
        data: {'email': email},
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        return data['success'] == true;
      }
      return false;
    } on DioException catch (e) {
      Logger.error(
        'Resend verification code error',
        feature: 'auth',
        screen: 'auth_remote_data_source',
        error: e,
      );
      
      // Handle rate limiting (429) and cooldown
      if (e.response?.statusCode == 429) {
        final errorData = e.response?.data;
        final cooldownUntil = errorData?['cooldown_until'] as String?;
        final cooldownSeconds = errorData?['cooldown_seconds'] as int?;
        
        throw VerificationCooldownException(
          message: errorData?['error']?['message'] ?? 
                   errorData?['message'] ?? 
                   'Please wait before requesting another code.',
          cooldownUntil: cooldownUntil != null 
              ? DateTime.tryParse(cooldownUntil) 
              : null,
          cooldownSeconds: cooldownSeconds ?? 60,
        );
      }
      
      return false;
    } catch (e) {
      if (e is VerificationCooldownException) rethrow;
      Logger.error(
        'Unexpected error resending verification code',
        feature: 'auth',
        screen: 'auth_remote_data_source',
        error: e,
      );
      return false;
    }
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
}

