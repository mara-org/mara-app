import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/health/daily_sleep_entry.dart';
import '../../core/models/health/daily_steps_entry.dart';
import '../../core/models/health/daily_water_intake_entry.dart';
import '../../core/di/dependency_injection.dart';
import '../../features/health/data/datasources/local_health_data_source.dart';
import '../../features/health/data/repositories/health_tracking_repository_impl.dart';
import '../../features/health/domain/repositories/health_tracking_repository.dart';

/// Provider for [LocalHealthDataSource].
final localHealthDataSourceProvider = Provider<LocalHealthDataSource>((ref) {
  return LocalHealthDataSource();
});

/// Provider for [HealthTrackingRepository].
final healthTrackingRepositoryProvider =
    Provider<HealthTrackingRepository>((ref) {
  final localDataSource = ref.read(localHealthDataSourceProvider);
  final healthDataService = ref.read(healthDataServiceProvider);
  return HealthTrackingRepositoryImpl(localDataSource, healthDataService);
});

/// Provider for today's steps entry.
///
/// Returns null if no steps data exists for today.
final todayStepsProvider = FutureProvider<DailyStepsEntry?>((ref) async {
  final repository = ref.read(healthTrackingRepositoryProvider);
  return await repository.getTodaySteps();
});

/// Provider for today's sleep entry.
///
/// Returns null if no sleep data exists for today.
final todaySleepProvider = FutureProvider<DailySleepEntry?>((ref) async {
  final repository = ref.read(healthTrackingRepositoryProvider);
  return await repository.getTodaySleep();
});

/// Provider for today's water intake entry.
///
/// Returns null if no water data exists for today.
final todayWaterProvider = FutureProvider<DailyWaterIntakeEntry?>((ref) async {
  final repository = ref.read(healthTrackingRepositoryProvider);
  return await repository.getTodayWater();
});

/// Provider for steps history.
///
/// Returns the last 30 days of steps entries by default.
final stepsHistoryProvider =
    FutureProvider.family<List<DailyStepsEntry>, int>((ref, limit) async {
  final repository = ref.read(healthTrackingRepositoryProvider);
  return await repository.getStepsHistory(limit: limit);
});

/// Provider for sleep history.
///
/// Returns the last 30 days of sleep entries by default.
final sleepHistoryProvider =
    FutureProvider.family<List<DailySleepEntry>, int>((ref, limit) async {
  final repository = ref.read(healthTrackingRepositoryProvider);
  return await repository.getSleepHistory(limit: limit);
});

/// Provider for water intake history.
///
/// Returns the last 30 days of water intake entries by default.
final waterHistoryProvider =
    FutureProvider.family<List<DailyWaterIntakeEntry>, int>((ref, limit) async {
  final repository = ref.read(healthTrackingRepositoryProvider);
  return await repository.getWaterHistory(limit: limit);
});

