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
      // Always try to sync from device first (it's the source of truth)
      if (_healthDataService != null) {
        try {
          final hasPermissions = await _healthDataService!.hasPermissions();
          if (hasPermissions) {
            final steps = await _healthDataService!.getTodaySteps();
            if (steps != null && steps > 0) {
              // Save to local storage
              final today = DateTime.now();
              final todayDate = DateTime(today.year, today.month, today.day);
              final stepsEntry = DailyStepsEntry(
                date: todayDate,
                steps: steps,
                lastUpdatedAt: DateTime.now(),
              );
              await _localDataSource.saveStepsEntry(stepsEntry);
              Logger.info(
                'HealthTrackingRepository: Synced steps data from HealthKit/Google Fit: $steps steps',
                feature: 'health',
                screen: 'health_repository',
              );
              return stepsEntry;
            } else {
              Logger.info(
                'HealthTrackingRepository: No steps data from device (returned: $steps)',
                feature: 'health',
                screen: 'health_repository',
              );
            }
          } else {
            Logger.warning(
              'HealthTrackingRepository: No permissions to access steps data',
              feature: 'health',
              screen: 'health_repository',
            );
          }
        } catch (e, stackTrace) {
          Logger.error(
            'HealthTrackingRepository: Error syncing steps from HealthKit/Google Fit: $e',
            feature: 'health',
            screen: 'health_repository',
            error: e,
            stackTrace: stackTrace,
          );
        }
      }

      // Fallback to local storage if sync failed or returned no data
      final localEntry = await _localDataSource.getTodaySteps();
      if (localEntry != null) {
        Logger.info(
          'HealthTrackingRepository: Using local steps data: ${localEntry.steps} steps',
          feature: 'health',
          screen: 'health_repository',
        );
      }
      return localEntry;
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
      // Check local storage first
      final localEntry = await _localDataSource.getTodaySleep();

      // Only sync if we don't have recent data (synced in last 5 minutes)
      final shouldSync = localEntry == null ||
          DateTime.now().difference(localEntry.lastUpdatedAt).inMinutes > 5;

      // First, try to get sleep data from HealthKit/Google Fit
      if (shouldSync && _healthDataService != null) {
        try {
          final hasPermissions = await _healthDataService!.hasPermissions();
          Logger.info(
            'HealthTrackingRepository: Checking sleep permissions: $hasPermissions',
            feature: 'health',
            screen: 'health_repository',
          );

          if (hasPermissions) {
            final sleepHours = await _healthDataService!.getTodaySleepHours();
            Logger.info(
              'HealthTrackingRepository: Retrieved sleep hours from device: $sleepHours',
              feature: 'health',
              screen: 'health_repository',
            );

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
            } else {
              Logger.warning(
                'HealthTrackingRepository: No sleep data available from device (returned: $sleepHours)',
                feature: 'health',
                screen: 'health_repository',
              );
            }
          } else {
            Logger.warning(
              'HealthTrackingRepository: No permissions to access sleep data',
              feature: 'health',
              screen: 'health_repository',
            );
          }
        } catch (e, stackTrace) {
          Logger.error(
            'HealthTrackingRepository: Error syncing sleep from HealthKit/Google Fit: $e',
            feature: 'health',
            screen: 'health_repository',
            error: e,
            stackTrace: stackTrace,
          );
        }
      }

      // Fallback to local storage
      return localEntry;
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
      // Try to sync from HealthKit/Google Fit first
      if (_healthDataService != null) {
        try {
          final hasPermissions = await _healthDataService!.hasPermissions();
          if (hasPermissions) {
            final waterLiters = await _healthDataService!.getTodayWaterLiters();
            if (waterLiters != null && waterLiters > 0) {
              // Save to local storage
              final today = DateTime.now();
              final todayDate = DateTime(today.year, today.month, today.day);
              final waterEntry = DailyWaterIntakeEntry(
                date: todayDate,
                waterLiters: waterLiters,
                lastUpdatedAt: DateTime.now(),
              );
              await _localDataSource.saveWaterIntakeEntry(waterEntry);
              Logger.info(
                'HealthTrackingRepository: Synced water data from HealthKit/Google Fit: ${waterLiters.toStringAsFixed(2)}L',
                feature: 'health',
                screen: 'health_repository',
              );
              return waterEntry;
            } else {
              Logger.info(
                'HealthTrackingRepository: No water data from device (returned: $waterLiters)',
                feature: 'health',
                screen: 'health_repository',
              );
            }
          } else {
            Logger.warning(
              'HealthTrackingRepository: No permissions to access water data',
              feature: 'health',
              screen: 'health_repository',
            );
          }
        } catch (e, stackTrace) {
          Logger.error(
            'HealthTrackingRepository: Error syncing water from HealthKit/Google Fit: $e',
            feature: 'health',
            screen: 'health_repository',
            error: e,
            stackTrace: stackTrace,
          );
        }
      }

      // Fallback to local storage if sync failed or returned no data
      final localEntry = await _localDataSource.getTodayWater();
      if (localEntry == null) {
        // Return null to show 0L in UI
        return null;
      }

      return localEntry;
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
        extra: {
          'waterLiters': entry.waterLiters,
          'date': entry.date.toString()
        },
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
  Future<Map<String, int>> syncAllHistoricalData() async {
    int sleepDaysSynced = 0;
    int stepsDaysSynced = 0;
    int waterDaysSynced = 0;

    try {
      if (_healthDataService == null) {
        Logger.warning(
          'HealthTrackingRepository: Health data service not available for sync',
          feature: 'health',
          screen: 'health_repository',
        );
        return {'sleepDays': 0, 'stepsDays': 0, 'waterDays': 0};
      }

      final hasPermissions = await _healthDataService!.hasPermissions();
      if (!hasPermissions) {
        Logger.warning(
          'HealthTrackingRepository: No permissions to sync historical data',
          feature: 'health',
          screen: 'health_repository',
        );
        return {'sleepDays': 0, 'stepsDays': 0, 'waterDays': 0};
      }

      // Sync all sleep data
      try {
        Logger.info(
          'HealthTrackingRepository: Starting sync of all historical sleep data',
          feature: 'health',
          screen: 'health_repository',
        );

        final allSleepData = await _healthDataService!.getAllSleepData();

        for (final entry in allSleepData.entries) {
          try {
            // Parse date string (YYYY-MM-DD)
            final dateParts = entry.key.split('-');
            final date = DateTime(
              int.parse(dateParts[0]),
              int.parse(dateParts[1]),
              int.parse(dateParts[2]),
            );

            final sleepEntry = DailySleepEntry(
              date: date,
              hours: entry.value,
              lastUpdatedAt: DateTime.now(),
            );

            await _localDataSource.saveSleepEntry(sleepEntry);
            sleepDaysSynced++;
          } catch (e) {
            Logger.warning(
              'HealthTrackingRepository: Error saving sleep entry for ${entry.key}: $e',
              feature: 'health',
              screen: 'health_repository',
            );
          }
        }

        Logger.info(
          'HealthTrackingRepository: Synced $sleepDaysSynced days of sleep data',
          feature: 'health',
          screen: 'health_repository',
        );
      } catch (e, stackTrace) {
        Logger.error(
          'HealthTrackingRepository: Error syncing sleep data',
          error: e,
          stackTrace: stackTrace,
          feature: 'health',
          screen: 'health_repository',
        );
      }

      // Sync all steps data
      try {
        Logger.info(
          'HealthTrackingRepository: Starting sync of all historical steps data',
          feature: 'health',
          screen: 'health_repository',
        );

        final allStepsData = await _healthDataService!.getAllStepsData();

        for (final entry in allStepsData.entries) {
          try {
            // Parse date string (YYYY-MM-DD)
            final dateParts = entry.key.split('-');
            final date = DateTime(
              int.parse(dateParts[0]),
              int.parse(dateParts[1]),
              int.parse(dateParts[2]),
            );

            final stepsEntry = DailyStepsEntry(
              date: date,
              steps: entry.value,
              lastUpdatedAt: DateTime.now(),
            );

            await _localDataSource.saveStepsEntry(stepsEntry);
            stepsDaysSynced++;
          } catch (e) {
            Logger.warning(
              'HealthTrackingRepository: Error saving steps entry for ${entry.key}: $e',
              feature: 'health',
              screen: 'health_repository',
            );
          }
        }

        Logger.info(
          'HealthTrackingRepository: Synced $stepsDaysSynced days of steps data',
          feature: 'health',
          screen: 'health_repository',
        );
      } catch (e, stackTrace) {
        Logger.error(
          'HealthTrackingRepository: Error syncing steps data',
          error: e,
          stackTrace: stackTrace,
          feature: 'health',
          screen: 'health_repository',
        );
      }

      // Sync all water data
      try {
        Logger.info(
          'HealthTrackingRepository: Starting sync of all historical water data',
          feature: 'health',
          screen: 'health_repository',
        );

        final allWaterData = await _healthDataService!.getAllWaterData();

        for (final entry in allWaterData.entries) {
          try {
            // Parse date string (YYYY-MM-DD)
            final dateParts = entry.key.split('-');
            final date = DateTime(
              int.parse(dateParts[0]),
              int.parse(dateParts[1]),
              int.parse(dateParts[2]),
            );

            final waterEntry = DailyWaterIntakeEntry(
              date: date,
              waterLiters: entry.value,
              lastUpdatedAt: DateTime.now(),
            );

            await _localDataSource.saveWaterIntakeEntry(waterEntry);
            waterDaysSynced++;
          } catch (e) {
            Logger.warning(
              'HealthTrackingRepository: Error saving water entry for ${entry.key}: $e',
              feature: 'health',
              screen: 'health_repository',
            );
          }
        }

        Logger.info(
          'HealthTrackingRepository: Synced $waterDaysSynced days of water data',
          feature: 'health',
          screen: 'health_repository',
        );
      } catch (e, stackTrace) {
        Logger.error(
          'HealthTrackingRepository: Error syncing water data',
          error: e,
          stackTrace: stackTrace,
          feature: 'health',
          screen: 'health_repository',
        );
      }

      return {
        'sleepDays': sleepDaysSynced,
        'stepsDays': stepsDaysSynced,
        'waterDays': waterDaysSynced,
      };
    } catch (e, stackTrace) {
      Logger.error(
        'HealthTrackingRepository: Error in syncAllHistoricalData',
        error: e,
        stackTrace: stackTrace,
        feature: 'health',
        screen: 'health_repository',
      );
      return {
        'sleepDays': sleepDaysSynced,
        'stepsDays': stepsDaysSynced,
        'waterDays': waterDaysSynced,
      };
    }
  }

  @override
  Future<void> syncWithRemoteStub() async {
    // No-op: local-only storage for now
    // Future implementation will sync with backend
  }
}
