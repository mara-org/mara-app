import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/local_cache.dart';
import '../analytics/analytics_service.dart';
import '../feature_flags/feature_flag_service.dart';
import '../feature_flags/firebase_remote_config_service.dart';
import '../services/app_review_service.dart';
import '../services/share_app_service.dart';
import '../services/health_data_service.dart';
import '../services/health_goals_service.dart';
import '../services/notification_service.dart';
import '../services/health_insights_service.dart';
import '../services/health_summary_service.dart';
import '../services/health_statistics_service.dart';
import '../services/streak_service.dart';
import '../services/achievement_service.dart';
import '../services/biometric_auth_service.dart';
import '../services/data_export_service.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/models/auth_result.dart';
import '../../features/auth/domain/models/user.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';

/// Dependency Injection container using Riverpod.
///
/// This provides a centralized way to register and access dependencies.
/// It makes it easy to swap implementations for testing.
class DependencyInjection {
  /// Initializes all dependencies.
  ///
  /// This should be called once at app startup.
  static Future<void> initialize() async {
    // Core services are already initialized in main.dart
    // This is here for future expansion
  }
}

// ============================================================================
// Core Services Providers
// ============================================================================

/// Provider for [LocalCache].
final localCacheProvider = Provider<LocalCache>((ref) {
  return LocalCache();
});

/// Provider for [AnalyticsService].
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

/// Provider for [RemoteConfigService].
///
/// This provides the remote config service for feature flags.
/// FeatureFlagService.init() should be called with this service.
final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  // Use Firebase Remote Config if available
  return FirebaseRemoteConfigService();
});

/// Provider for [IAppReviewService].
///
/// This provides the app review service for opening store listings
/// and handling in-app reviews.
final appReviewServiceProvider = Provider<IAppReviewService>((final ref) {
  return AppReviewService();
});

/// Provider for [IShareAppService].
///
/// This provides the share app service for sharing the app
/// with platform-aware store URLs.
final shareAppServiceProvider = Provider<IShareAppService>((final ref) {
  return ShareAppService();
});

/// Provider for [IHealthDataService].
///
/// This provides access to device health data (HealthKit on iOS, Google Fit on Android).
final healthDataServiceProvider = Provider<IHealthDataService>((final ref) {
  return HealthDataService();
});

/// Provider for [HealthGoalsService].
///
/// This provides health goals management (save/load goals).
final healthGoalsServiceProvider = Provider<HealthGoalsService>((final ref) {
  return HealthGoalsService();
});

/// Provider for [INotificationService].
///
/// This provides local notification scheduling for health reminders.
final notificationServiceProvider = Provider<INotificationService>((final ref) {
  return NotificationService();
});

/// Provider for [HealthInsightsService].
///
/// This provides health insights generation from tracking data.
final healthInsightsServiceProvider = Provider<HealthInsightsService>((final ref) {
  return HealthInsightsService();
});

/// Provider for [HealthSummaryService].
///
/// This provides weekly and monthly health summaries.
final healthSummaryServiceProvider = Provider<HealthSummaryService>((final ref) {
  return HealthSummaryService();
});

/// Provider for [HealthStatisticsService].
///
/// This provides all-time health statistics.
final healthStatisticsServiceProvider = Provider<HealthStatisticsService>((final ref) {
  return HealthStatisticsService();
});

/// Provider for [StreakService].
///
/// This provides streak calculation for health goals.
final streakServiceProvider = Provider<StreakService>((final ref) {
  return StreakService();
});

/// Provider for [AchievementService].
///
/// This provides achievement/badge management.
final achievementServiceProvider = Provider<AchievementService>((final ref) {
  return AchievementService();
});

/// Provider for [IBiometricAuthService].
///
/// This provides biometric authentication (Face ID, Touch ID, Fingerprint).
final biometricAuthServiceProvider = Provider<IBiometricAuthService>((final ref) {
  return BiometricAuthService();
});

/// Provider for [DataExportService].
///
/// This provides health data export functionality (JSON, CSV).
final dataExportServiceProvider = Provider<DataExportService>((final ref) {
  return DataExportService();
});

// ============================================================================
// Auth Feature Providers
// ============================================================================

/// Provider for [AuthLocalDataSource].
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final localCache = ref.read(localCacheProvider);
  return AuthLocalDataSource(localCache);
});

/// Provider for [AuthRemoteDataSource].
///
/// TODO: Replace with actual implementation when backend is available.
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  // Placeholder implementation - will be replaced when backend is ready
  throw UnimplementedError(
    'AuthRemoteDataSource implementation needed when backend is available',
  );
});

/// Provider for [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final localDataSource = ref.read(authLocalDataSourceProvider);
  // For now, use only local data source until backend is available
  // When backend is ready, uncomment:
  // final remoteDataSource = ref.read(authRemoteDataSourceProvider);
  // return AuthRepositoryImpl(remoteDataSource, localDataSource);

  // Temporary: Create repository with null remote data source
  // This will be replaced when backend is available
  return AuthRepositoryImpl(
    // remoteDataSource, // TODO: Uncomment when backend is ready
    _PlaceholderRemoteDataSource(),
    localDataSource,
  );
});

/// Provider for [SignInUseCase].
final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return SignInUseCase(authRepository);
});

/// Provider for [SignUpUseCase].
final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return SignUpUseCase(authRepository);
});

// ============================================================================
// Placeholder Implementation
// ============================================================================

/// Placeholder remote data source until backend is available.
///
/// This prevents the app from crashing while backend is being developed.
class _PlaceholderRemoteDataSource implements AuthRemoteDataSource {
  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    // Placeholder - will be replaced with actual API call
    throw UnimplementedError('Backend API not yet available');
  }

  @override
  Future<AuthResult> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    throw UnimplementedError('Backend API not yet available');
  }

  @override
  Future<void> signOut() async {
    throw UnimplementedError('Backend API not yet available');
  }

  @override
  Future<User?> getCurrentUser() async {
    throw UnimplementedError('Backend API not yet available');
  }

  @override
  Future<bool> sendPasswordResetEmail(String email) async {
    throw UnimplementedError('Backend API not yet available');
  }

  @override
  Future<bool> verifyEmailCode(String code) async {
    throw UnimplementedError('Backend API not yet available');
  }

  @override
  Future<bool> resendVerificationCode() async {
    throw UnimplementedError('Backend API not yet available');
  }
}
