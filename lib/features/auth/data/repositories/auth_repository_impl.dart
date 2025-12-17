import '../../domain/models/auth_result.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source_impl.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/providers/app_capabilities_provider.dart';
import '../../../../core/network/api_exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Implementation of [AuthRepository].
///
/// This coordinates between remote and local data sources.
/// In a real implementation, this would call actual backend APIs.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource? _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (_remoteDataSource == null) {
        throw Exception('Remote data source not available');
      }
      
      final result = await _remoteDataSource!.signIn(
        email: email,
        password: password,
      );

      if (result.isSuccess && result.user != null) {
        // Save user to local storage
        await _localDataSource.saveUser(result.user!);
      }

      return result;
    } catch (e, stackTrace) {
      Logger.error(
        'AuthRepository: signIn error',
        feature: 'auth',
        screen: 'auth_repository',
        error: e,
        stackTrace: stackTrace,
      );

      // Determine error type from exception
      final errorType = _mapExceptionToErrorType(e);
      return AuthResult.failureResult(
        e.toString(),
        errorType,
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
      if (_remoteDataSource == null) {
        throw Exception('Remote data source not available');
      }
      
      final result = await _remoteDataSource!.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (result.isSuccess && result.user != null) {
        // Save user to local storage
        await _localDataSource.saveUser(result.user!);
      }

      return result;
    } catch (e, stackTrace) {
      Logger.error(
        'AuthRepository: signUp error',
        feature: 'auth',
        screen: 'auth_repository',
        error: e,
        stackTrace: stackTrace,
      );

      final errorType = _mapExceptionToErrorType(e);
      return AuthResult.failureResult(
        e.toString(),
        errorType,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      if (_remoteDataSource != null) {
        await _remoteDataSource!.signOut();
      }
      await _localDataSource.clearUser();
      
      // Clear backend session capabilities
      if (_sessionService != null) {
        _sessionService!.clearCapabilities();
      }
      if (_ref != null) {
        _ref!.read(appCapabilitiesProvider.notifier).clear();
      }
      
      Logger.info(
        'AuthRepository: signOut successful',
        feature: 'auth',
        screen: 'auth_repository',
      );
    } catch (e, stackTrace) {
      Logger.error(
        'AuthRepository: signOut error',
        feature: 'auth',
        screen: 'auth_repository',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      // Try remote first if available
      if (_remoteDataSource != null) {
        final remoteUser = await _remoteDataSource!.getCurrentUser();
        if (remoteUser != null) {
          await _localDataSource.saveUser(remoteUser);
          return remoteUser;
        }
      }

      // Fallback to local storage
      final localUser = await _localDataSource.getUser();
      return localUser;
    } catch (e, stackTrace) {
      Logger.error(
        'AuthRepository: getCurrentUser error',
        feature: 'auth',
        screen: 'auth_repository',
        error: e,
        stackTrace: stackTrace,
      );
      // Fallback to local storage on error
      return await _localDataSource.getUser();
    }
  }

  @override
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      // TODO: Call backend API
      Logger.info(
        'AuthRepository: sendPasswordResetEmail called (placeholder)',
        feature: 'auth',
        screen: 'auth_repository',
      );
      return true; // Placeholder
    } catch (e, stackTrace) {
      Logger.error(
        'AuthRepository: sendPasswordResetEmail error',
        feature: 'auth',
        screen: 'auth_repository',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  @override
  Future<bool> verifyEmailCode(String code) async {
    try {
      if (_remoteDataSource == null) {
        throw Exception('Remote data source not available');
      }
      
      // Get email from local storage
      final user = await _localDataSource.getUser();
      if (user == null) {
        return false;
      }
      
      return await _remoteDataSource!.verifyEmailCode(code, user.email);
    } on VerificationRateLimitException {
      // Re-throw rate limit exceptions so UI can handle them
      rethrow;
    } catch (e, stackTrace) {
      Logger.error(
        'AuthRepository: verifyEmailCode error',
        feature: 'auth',
        screen: 'auth_repository',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  @override
  Future<bool> resendVerificationCode() async {
    try {
      if (_remoteDataSource == null) {
        throw Exception('Remote data source not available');
      }
      
      // Get email from local storage
      final user = await _localDataSource.getUser();
      if (user == null) {
        return false;
      }
      
      return await _remoteDataSource!.resendVerificationCode(user.email);
    } on VerificationCooldownException {
      // Re-throw cooldown exceptions so UI can handle them
      rethrow;
    } catch (e, stackTrace) {
      Logger.error(
        'AuthRepository: resendVerificationCode error',
        feature: 'auth',
        screen: 'auth_repository',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Maps exceptions to [AuthErrorType].
  AuthErrorType _mapExceptionToErrorType(Object error) {
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('network') || errorString.contains('connection')) {
      return AuthErrorType.networkError;
    } else if (errorString.contains('invalid') ||
        errorString.contains('credential')) {
      return AuthErrorType.invalidCredentials;
    } else if (errorString.contains('email') &&
        errorString.contains('verify')) {
      return AuthErrorType.emailNotVerified;
    } else {
      return AuthErrorType.unknown;
    }
  }
}
