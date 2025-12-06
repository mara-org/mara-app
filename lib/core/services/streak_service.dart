import '../models/health/daily_sleep_entry.dart';
import '../models/health/daily_steps_entry.dart';
import '../models/health/daily_water_intake_entry.dart';

/// Streak information for a health metric.
class HealthStreak {
  final int currentStreak;
  final int longestStreak;
  final DateTime? streakStartDate;

  const HealthStreak({
    required this.currentStreak,
    required this.longestStreak,
    this.streakStartDate,
  });
}

/// Service for calculating health streaks.
class StreakService {
  /// Calculate steps streak based on goal.
  HealthStreak calculateStepsStreak({
    required List<DailyStepsEntry> stepsHistory,
    required int dailyGoal,
  }) {
    if (stepsHistory.isEmpty) {
      return const HealthStreak(currentStreak: 0, longestStreak: 0);
    }

    // Sort by date descending
    final sorted = List<DailyStepsEntry>.from(stepsHistory)
      ..sort((a, b) => b.date.compareTo(a.date));

    int currentStreak = 0;
    int longestStreak = 0;
    DateTime? streakStartDate;
    DateTime? currentStreakStart;

    final today = DateTime.now();
    DateTime checkDate = DateTime(today.year, today.month, today.day);

    for (int i = 0; i < 365; i++) {
      final entry = sorted.firstWhere(
        (e) =>
            e.date.year == checkDate.year &&
            e.date.month == checkDate.month &&
            e.date.day == checkDate.day,
        orElse: () => DailyStepsEntry(
          date: checkDate,
          steps: 0,
          lastUpdatedAt: checkDate,
        ),
      );

      if (entry.steps >= dailyGoal) {
        if (currentStreak == 0) {
          currentStreakStart = checkDate;
        }
        currentStreak++;
        longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;
        streakStartDate = currentStreakStart;
      } else {
        currentStreak = 0;
        currentStreakStart = null;
      }

      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return HealthStreak(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      streakStartDate: streakStartDate,
    );
  }

  /// Calculate sleep streak based on goal.
  HealthStreak calculateSleepStreak({
    required List<DailySleepEntry> sleepHistory,
    required double dailyGoal,
  }) {
    if (sleepHistory.isEmpty) {
      return const HealthStreak(currentStreak: 0, longestStreak: 0);
    }

    final sorted = List<DailySleepEntry>.from(sleepHistory)
      ..sort((a, b) => b.date.compareTo(a.date));

    int currentStreak = 0;
    int longestStreak = 0;
    DateTime? streakStartDate;
    DateTime? currentStreakStart;

    final today = DateTime.now();
    DateTime checkDate = DateTime(today.year, today.month, today.day);

    for (int i = 0; i < 365; i++) {
      final entry = sorted.firstWhere(
        (e) =>
            e.date.year == checkDate.year &&
            e.date.month == checkDate.month &&
            e.date.day == checkDate.day,
        orElse: () => DailySleepEntry(
          date: checkDate,
          hours: 0.0,
          lastUpdatedAt: checkDate,
        ),
      );

      if (entry.hours >= dailyGoal) {
        if (currentStreak == 0) {
          currentStreakStart = checkDate;
        }
        currentStreak++;
        longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;
        streakStartDate = currentStreakStart;
      } else {
        currentStreak = 0;
        currentStreakStart = null;
      }

      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return HealthStreak(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      streakStartDate: streakStartDate,
    );
  }

  /// Calculate water streak based on goal.
  HealthStreak calculateWaterStreak({
    required List<DailyWaterIntakeEntry> waterHistory,
    required double dailyGoal,
  }) {
    if (waterHistory.isEmpty) {
      return const HealthStreak(currentStreak: 0, longestStreak: 0);
    }

    final sortedHistory = List<DailyWaterIntakeEntry>.from(waterHistory)
      ..sort((a, b) => b.date.compareTo(a.date));

    int currentStreak = 0;
    int longestStreak = 0;
    DateTime? streakStartDate;
    DateTime? currentStreakStart;

    final today = DateTime.now();
    DateTime checkDate = DateTime(today.year, today.month, today.day);

    for (int i = 0; i < 365; i++) {
      final entry = sortedHistory.firstWhere(
        (e) =>
            e.date.year == checkDate.year &&
            e.date.month == checkDate.month &&
            e.date.day == checkDate.day,
        orElse: () => DailyWaterIntakeEntry(
          date: checkDate,
          waterLiters: 0.0,
          lastUpdatedAt: checkDate,
        ),
      );

      if (entry.waterLiters >= dailyGoal) {
        if (currentStreak == 0) {
          currentStreakStart = checkDate;
        }
        currentStreak++;
        longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;
        streakStartDate = currentStreakStart;
      } else {
        currentStreak = 0;
        currentStreakStart = null;
      }

      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return HealthStreak(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      streakStartDate: streakStartDate,
    );
  }
}

