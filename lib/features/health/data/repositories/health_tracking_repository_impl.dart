import '../../../../core/models/health/daily_sleep_entry.dart';
import '../../../../core/models/health/daily_steps_entry.dart';
import '../../../../core/models/health/daily_water_intake_entry.dart';
import '../../../../core/services/health_data_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/repositories/health_tracking_repository.dart';
import '../datasources/local_health_data_source.dart';

/// Implementation of [HealthTrackingRepository].
///
/// Coordinates with local data source for health tracking operations.
/// Also integrates with HealthKit/Google Fit to sync sleep data.
/// All operations are local-only (no backend calls).
class HealthTrackingRepositoryImpl implements HealthTrackingRepository {
  final LocalHealthDataSource _localDataSource;
  final IHealthDataService? _healthDataService;

  HealthTrackingRepositoryImpl(
    this._localDataSource, [
    this._healthDataService,
  ]);

  @override
  Future<DailyStepsEntry?> getTodaySteps() async {
    try {
      return await _localDataSource.getTodaySteps();
    } catch (e, stackTrace) {
      Logger.error(
        'HealthTrackingRepository: getTodaySteps error',
        feature: 'health',
        screen: 'health_repository',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  Future<DailySleepEntry?> getTodaySleep() async {
    try {
      // First, try to get sleep data from HealthKit/Google Fit
      if (_healthDataService != null) {
        try {
          final hasPermissions = await _healthDataService!.hasPermissions();
          if (hasPermissions) {
            final sleepHours = await _healthDataService!.getTodaySleepHours();
            if (sleepHours != null && sleepHours > 0) {
              // Save to local storage
              final today = DateTime.now();
              final todayDate = DateTime(today.year, today.month, today.day);
              final sleepEntry = DailySleepEntry(
                date: todayDate,
                hours: sleepHours,
                lastUpdatedAt: DateTime.now(),
              );
              await _localDataSource.saveSleepEntry(sleepEntry);
              Logger.info(
                'HealthTrackingRepository: Synced sleep data from HealthKit/Google Fit: ${sleepHours.toStringAsFixed(2)} hours',
                feature: 'health',
                screen: 'health_repository',
              );
              return sleepEntry;
            }
          }
        } catch (e) {
          Logger.warning(
            'HealthTrackingRepository: Could not sync sleep from HealthKit/Google Fit, falling back to local storage: $e',
            feature: 'health',
            screen: 'health_repository',
          );
        }
      }

      // Fallback to local storage
      return await _localDataSource.getTodaySleep();
    } catch (e, stackTrace) {
      Logger.error(
        'HealthTrackingRepository: getTodaySleep error',
        feature: 'health',
        screen: 'health_repository',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  Future<DailyWaterIntakeEntry?> getTodayWater() async {
    try {
      return await _localDataSource.getTodayWater();
    } catch (e, stackTrace) {
      Logger.error(
        'HealthTrackingRepository: getTodayWater error',
        feature: 'health',
        screen: 'health_repository',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  Future<void> saveStepsEntry(DailyStepsEntry entry) async {
    try {
      if (!entry.isValid) {
        Logger.warning(
          'HealthTrackingRepository: Attempted to save invalid steps entry',
          feature: 'health',
          screen: 'health_repository',
        );
        return;
      }
      await _localDataSource.saveStepsEntry(entry);
      Logger.info(
        'HealthTrackingRepository: Steps entry saved',
        feature: 'health',
        screen: 'health_repository',
        extra: {'steps': entry.steps, 'date': entry.date.toString()},
      );
    } catch (e, stackTrace) {
      Logger.error(
        'HealthTrackingRepository: saveStepsEntry error',
        feature: 'health',
        screen: 'health_repository',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> saveSleepEntry(DailySleepEntry entry) async {
    // Sleep entries can ONLY be saved from HealthKit/Google Fit sync.
    // Manual sleep entry is not allowed - sleep data must come from device health services.
    try {
      if (!entry.isValid) {
        Logger.warning(
          'HealthTrackingRepository: Attempted to save invalid sleep entry',
          feature: 'health',
          screen: 'health_repository',
        );
        return;
      }
      // Note: This method should only be called from HealthKit/Google Fit sync operations.
      // Manual sleep entry is disabled - all sleep data must come from device health services.
      await _localDataSource.saveSleepEntry(entry);
      Logger.info(
        'HealthTrackingRepository: Sleep entry saved from HealthKit/Google Fit sync',
        feature: 'health',
        screen: 'health_repository',
        extra: {'hours': entry.hours, 'date': entry.date.toString()},
      );
    } catch (e, stackTrace) {
      Logger.error(
        'HealthTrackingRepository: saveSleepEntry error',
        feature: 'health',
        screen: 'health_repository',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> saveWaterIntakeEntry(DailyWaterIntakeEntry entry) async {
    try {
      if (!entry.isValid) {
        Logger.warning(
          'HealthTrackingRepository: Attempted to save invalid water entry',
          feature: 'health',
          screen: 'health_repository',
        );
        return;
      }
      await _localDataSource.saveWaterIntakeEntry(entry);
      Logger.info(
        'HealthTrackingRepository: Water intake entry saved',
        feature: 'health',
        screen: 'health_repository',
        extra: {'waterLiters': entry.waterLiters, 'date': entry.date.toString()},
      );
    } catch (e, stackTrace) {
      Logger.error(
        'HealthTrackingRepository: saveWaterIntakeEntry error',
        feature: 'health',
        screen: 'health_repository',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<List<DailyStepsEntry>> getStepsHistory({int? limit}) async {
    try {
      return await _localDataSource.getStepsHistory(limit: limit);
    } catch (e, stackTrace) {
      Logger.error(
        'HealthTrackingRepository: getStepsHistory error',
        feature: 'health',
        screen: 'health_repository',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  @override
  Future<List<DailySleepEntry>> getSleepHistory({int? limit}) async {
    try {
      return await _localDataSource.getSleepHistory(limit: limit);
    } catch (e, stackTrace) {
      Logger.error(
        'HealthTrackingRepository: getSleepHistory error',
        feature: 'health',
        screen: 'health_repository',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  @override
  Future<List<DailyWaterIntakeEntry>> getWaterHistory({int? limit}) async {
    try {
      return await _localDataSource.getWaterHistory(limit: limit);
    } catch (e, stackTrace) {
      Logger.error(
        'HealthTrackingRepository: getWaterHistory error',
        feature: 'health',
        screen: 'health_repository',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  @override
  Future<void> syncWithRemoteStub() async {
    // No-op: local-only storage for now
    // Future implementation will sync with backend
  }
}

