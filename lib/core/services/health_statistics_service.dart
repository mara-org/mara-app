import '../models/health/daily_sleep_entry.dart';
import '../models/health/daily_steps_entry.dart';
import '../models/health/daily_water_intake_entry.dart';

/// All-time health statistics.
class HealthStatistics {
  final int totalStepsAllTime;
  final double totalSleepHoursAllTime;
  final double totalWaterLitersAllTime;
  final double averageDailySteps;
  final double averageDailySleep;
  final double averageDailyWater;
  final int? bestDaySteps;
  final double? bestDaySleep;
  final double? bestDayWater;
  final DateTime? bestDayStepsDate;
  final DateTime? bestDaySleepDate;
  final DateTime? bestDayWaterDate;
  final int totalDaysTracked;

  const HealthStatistics({
    required this.totalStepsAllTime,
    required this.totalSleepHoursAllTime,
    required this.totalWaterLitersAllTime,
    required this.averageDailySteps,
    required this.averageDailySleep,
    required this.averageDailyWater,
    this.bestDaySteps,
    this.bestDaySleep,
    this.bestDayWater,
    this.bestDayStepsDate,
    this.bestDaySleepDate,
    this.bestDayWaterDate,
    required this.totalDaysTracked,
  });
}

/// Service for calculating all-time health statistics.
class HealthStatisticsService {
  /// Calculate all-time statistics from health history.
  Future<HealthStatistics> calculateStatistics({
    required List<DailyStepsEntry> stepsHistory,
    required List<DailySleepEntry> sleepHistory,
    required List<DailyWaterIntakeEntry> waterHistory,
  }) async {
    // Calculate totals
    final totalSteps =
        stepsHistory.fold<int>(0, (sum, entry) => sum + entry.steps);
    final totalSleep =
        sleepHistory.fold<double>(0.0, (sum, entry) => sum + entry.hours);
    final totalWater =
        waterHistory.fold<double>(0.0, (sum, entry) => sum + entry.waterLiters);

    // Calculate averages
    final stepsCount = stepsHistory.length;
    final sleepCount = sleepHistory.length;
    final waterCount = waterHistory.length;

    final averageSteps = stepsCount > 0 ? totalSteps / stepsCount : 0.0;
    final averageSleep = sleepCount > 0 ? totalSleep / sleepCount : 0.0;
    final averageWater = waterCount > 0 ? totalWater / waterCount : 0.0;

    // Find best days
    DailyStepsEntry? bestStepsDay;
    DailySleepEntry? bestSleepDay;
    DailyWaterIntakeEntry? bestWaterDay;

    for (final entry in stepsHistory) {
      if (bestStepsDay == null || entry.steps > bestStepsDay.steps) {
        bestStepsDay = entry;
      }
    }

    for (final entry in sleepHistory) {
      if (bestSleepDay == null || entry.hours > bestSleepDay.hours) {
        bestSleepDay = entry;
      }
    }

    for (final entry in waterHistory) {
      if (bestWaterDay == null || entry.waterLiters > bestWaterDay.waterLiters) {
        bestWaterDay = entry;
      }
    }

    // Calculate total days tracked
    final allDates = <DateTime>{};
    for (final e in stepsHistory) {
      allDates.add(DateTime(e.date.year, e.date.month, e.date.day));
    }
    for (final e in sleepHistory) {
      allDates.add(DateTime(e.date.year, e.date.month, e.date.day));
    }
    for (final e in waterHistory) {
      allDates.add(DateTime(e.date.year, e.date.month, e.date.day));
    }

    return HealthStatistics(
      totalStepsAllTime: totalSteps,
      totalSleepHoursAllTime: totalSleep,
      totalWaterLitersAllTime: totalWater,
      averageDailySteps: averageSteps,
      averageDailySleep: averageSleep,
      averageDailyWater: averageWater,
      bestDaySteps: bestStepsDay?.steps,
      bestDaySleep: bestSleepDay?.hours,
      bestDayWater: bestWaterDay?.waterLiters,
      bestDayStepsDate: bestStepsDay?.date,
      bestDaySleepDate: bestSleepDay?.date,
      bestDayWaterDate: bestWaterDay?.date,
      totalDaysTracked: allDates.length,
    );
  }
}

