import '../../../../core/models/health/daily_sleep_entry.dart';
import '../../../../core/models/health/daily_steps_entry.dart';
import '../../../../core/models/health/daily_water_intake_entry.dart';

/// Repository interface for health tracking operations.
///
/// This is a domain layer interface that defines the contract
/// for health tracking operations. Implementations live in the data layer.
///
/// All operations are local-only (no backend calls).
/// Data is stored locally using JSON serialization.
abstract class HealthTrackingRepository {
  /// Gets today's steps entry.
  ///
  /// Returns null if no steps data exists for today.
  Future<DailyStepsEntry?> getTodaySteps();

  /// Gets today's sleep entry.
  ///
  /// Returns null if no sleep data exists for today.
  Future<DailySleepEntry?> getTodaySleep();

  /// Gets today's water intake entry.
  ///
  /// Returns null if no water data exists for today.
  Future<DailyWaterIntakeEntry?> getTodayWater();

  /// Saves a steps entry.
  ///
  /// If an entry for the same date exists, it will be updated.
  Future<void> saveStepsEntry(DailyStepsEntry entry);

  /// Saves a sleep entry.
  ///
  /// **IMPORTANT**: Sleep data can ONLY come from HealthKit/Google Fit sync.
  /// Manual sleep entry is NOT allowed. This method should only be called
  /// when syncing sleep data from device health services.
  ///
  /// If an entry for the same date exists, it will be updated.
  Future<void> saveSleepEntry(DailySleepEntry entry);

  /// Saves a water intake entry.
  ///
  /// If an entry for the same date exists, it will be updated.
  Future<void> saveWaterIntakeEntry(DailyWaterIntakeEntry entry);

  /// Gets steps history.
  ///
  /// Returns all steps entries sorted by date (most recent first).
  /// Use [limit] to restrict the number of entries returned.
  Future<List<DailyStepsEntry>> getStepsHistory({int? limit});

  /// Gets sleep history.
  ///
  /// Returns all sleep entries sorted by date (most recent first).
  /// Use [limit] to restrict the number of entries returned.
  Future<List<DailySleepEntry>> getSleepHistory({int? limit});

  /// Gets water intake history.
  ///
  /// Returns all water intake entries sorted by date (most recent first).
  /// Use [limit] to restrict the number of entries returned.
  Future<List<DailyWaterIntakeEntry>> getWaterHistory({int? limit});

  /// Syncs all historical sleep, steps, and water data from the device.
  ///
  /// Fetches all available sleep, steps, and water data from HealthKit/Google Fit
  /// and saves it to local storage. Returns the number of days synced.
  ///
  /// Returns a map with 'sleepDays', 'stepsDays', and 'waterDays' counts.
  Future<Map<String, int>> syncAllHistoricalData();

  /// Stub for future backend sync - currently a no-op.
  ///
  /// This method exists to prepare for future backend integration.
  /// Currently, it does nothing (local-only storage).
  /// When backend is available, this can be updated to sync local data.
  Future<void> syncWithRemoteStub() async {
    // No-op: local-only storage for now
    // Future implementation will sync with backend
  }
}
