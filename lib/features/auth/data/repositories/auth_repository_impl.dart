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
  final SessionService? _sessionService;
  final WidgetRef? _ref;

  AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource, {
    SessionService? sessionService,
    WidgetRef? ref,
  })  : _sessionService = sessionService,
        _ref = ref;

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
      if (_remoteDataSource == null) {
        throw Exception('Remote data source not available');
      }
      return await _remoteDataSource!.sendPasswordResetEmail(email);
    } on ApiException catch (e) {
      Logger.error(
        'AuthRepository: sendPasswordResetEmail error',
        feature: 'auth',
        screen: 'auth_repository',
        error: e,
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.error(
        'AuthRepository: sendPasswordResetEmail unexpected error',
        feature: 'auth',
        screen: 'auth_repository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('An unexpected error occurred when sending reset email.');
    }
  }

  @override
  Future<bool> verifyEmailCode(String code, {String? email}) async {
    throw UnimplementedError('Email verification is handled by Firebase via email links');
  }

  @override
  Future<bool> resendVerificationCode({String? email}) async {
    throw UnimplementedError('Email verification is handled by Firebase via email links');
  }

  @override
  Future<bool> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    throw UnimplementedError('Password reset is handled by Firebase via email links');
  }

  @override
  Future<bool> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    throw UnimplementedError('Password reset is handled by Firebase via email links');
  }

  @override
  Future<bool> sendDeleteAccountCode(String email) async {
    try {
      if (_remoteDataSource == null) {
        throw Exception('Remote data source not available');
      }
      return await _remoteDataSource!.sendDeleteAccountCode(email);
    } on ApiException catch (e) {
      Logger.error(
        'AuthRepository: sendDeleteAccountCode error',
        feature: 'auth',
        screen: 'auth_repository',
        error: e,
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.error(
        'AuthRepository: sendDeleteAccountCode unexpected error',
        feature: 'auth',
        screen: 'auth_repository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('An unexpected error occurred when sending delete account code.');
    }
  }

  @override
  Future<bool> deleteAccount({
    required String email,
    required String code,
  }) async {
    try {
      if (_remoteDataSource == null) {
        throw Exception('Remote data source not available');
      }
      final success = await _remoteDataSource!.deleteAccount(
        email: email,
        code: code,
      );
      
      if (success) {
        // Clear local user data after successful deletion
        await _localDataSource.clearUser();
        if (_sessionService != null) {
          _sessionService!.clearCapabilities();
        }
        if (_ref != null) {
          _ref!.read(appCapabilitiesProvider.notifier).clear();
        }
      }
      
      return success;
    } on ApiException catch (e) {
      Logger.error(
        'AuthRepository: deleteAccount error',
        feature: 'auth',
        screen: 'auth_repository',
        error: e,
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.error(
        'AuthRepository: deleteAccount unexpected error',
        feature: 'auth',
        screen: 'auth_repository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('An unexpected error occurred when deleting account.');
    }
  }

  /// Maps exceptions to [AuthErrorType].
  AuthErrorType _mapExceptionToErrorType(final Object error) {
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
