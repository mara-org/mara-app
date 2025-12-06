import '../models/health/daily_sleep_entry.dart';
import '../models/health/daily_steps_entry.dart';
import '../models/health/daily_water_intake_entry.dart';

/// Weekly or monthly health summary.
class HealthSummary {
  final DateTime startDate;
  final DateTime endDate;
  final int totalSteps;
  final double totalSleepHours;
  final double totalWaterLiters;
  final double averageSteps;
  final double averageSleepHours;
  final double averageWaterLiters;
  final int daysWithData;

  const HealthSummary({
    required this.startDate,
    required this.endDate,
    required this.totalSteps,
    required this.totalSleepHours,
    required this.totalWaterLiters,
    required this.averageSteps,
    required this.averageSleepHours,
    required this.averageWaterLiters,
    required this.daysWithData,
  });
}

/// Service for generating health summaries (weekly, monthly).
class HealthSummaryService {
  /// Generate weekly summary.
  Future<HealthSummary> generateWeeklySummary({
    required List<DailyStepsEntry> stepsHistory,
    required List<DailySleepEntry> sleepHistory,
    required List<DailyWaterIntakeEntry> waterHistory,
  }) async {
    final now = DateTime.now();
    final weekStart = now.subtract(const Duration(days: 7));

    return _generateSummary(
      stepsHistory: stepsHistory,
      sleepHistory: sleepHistory,
      waterHistory: waterHistory,
      startDate: weekStart,
      endDate: now,
    );
  }

  /// Generate monthly summary.
  Future<HealthSummary> generateMonthlySummary({
    required List<DailyStepsEntry> stepsHistory,
    required List<DailySleepEntry> sleepHistory,
    required List<DailyWaterIntakeEntry> waterHistory,
  }) async {
    final now = DateTime.now();
    final monthStart = now.subtract(const Duration(days: 30));

    return _generateSummary(
      stepsHistory: stepsHistory,
      sleepHistory: sleepHistory,
      waterHistory: waterHistory,
      startDate: monthStart,
      endDate: now,
    );
  }

  HealthSummary _generateSummary({
    required List<DailyStepsEntry> stepsHistory,
    required List<DailySleepEntry> sleepHistory,
    required List<DailyWaterIntakeEntry> waterHistory,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    // Filter entries within date range
    final stepsInRange = stepsHistory
        .where((e) => e.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            e.date.isBefore(endDate.add(const Duration(days: 1))))
        .toList();

    final sleepInRange = sleepHistory
        .where((e) => e.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            e.date.isBefore(endDate.add(const Duration(days: 1))))
        .toList();

    final waterInRange = waterHistory
        .where((e) => e.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            e.date.isBefore(endDate.add(const Duration(days: 1))))
        .toList();

    // Calculate totals
    final totalSteps = stepsInRange.fold<int>(0, (sum, e) => sum + e.steps);
    final totalSleep =
        sleepInRange.fold<double>(0.0, (sum, e) => sum + e.hours);
    final totalWater =
        waterInRange.fold<double>(0.0, (sum, e) => sum + e.waterLiters);

    // Calculate days with data
    final allDates = <DateTime>{};
    for (final e in stepsInRange) {
      allDates.add(DateTime(e.date.year, e.date.month, e.date.day));
    }
    for (final e in sleepInRange) {
      allDates.add(DateTime(e.date.year, e.date.month, e.date.day));
    }
    for (final e in waterInRange) {
      allDates.add(DateTime(e.date.year, e.date.month, e.date.day));
    }
    final daysWithData = allDates.length;

    // Calculate averages
    final daysInRange = endDate.difference(startDate).inDays + 1;
    final averageSteps = daysInRange > 0 ? totalSteps / daysInRange : 0.0;
    final averageSleep = daysInRange > 0 ? totalSleep / daysInRange : 0.0;
    final averageWater = daysInRange > 0 ? totalWater / daysInRange : 0.0;

    return HealthSummary(
      startDate: startDate,
      endDate: endDate,
      totalSteps: totalSteps,
      totalSleepHours: totalSleep,
      totalWaterLiters: totalWater,
      averageSteps: averageSteps,
      averageSleepHours: averageSleep,
      averageWaterLiters: averageWater,
      daysWithData: daysWithData,
    );
  }
}

