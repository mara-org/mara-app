import '../models/health/daily_sleep_entry.dart';
import '../models/health/daily_steps_entry.dart';
import '../models/health/daily_water_intake_entry.dart';
import '../utils/logger.dart';

/// Health insight data model.
class HealthInsight {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final InsightType type;

  const HealthInsight({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.type,
  });
}

enum InsightType { improvement, pattern, achievement, tip }

/// Service for generating health insights from local data.
///
/// Analyzes health tracking data to provide personalized insights.
class HealthInsightsService {
  /// Generate insights from health data.
  Future<List<HealthInsight>> generateInsights({
    required List<DailyStepsEntry> stepsHistory,
    required List<DailySleepEntry> sleepHistory,
    required List<DailyWaterIntakeEntry> waterHistory,
  }) async {
    final insights = <HealthInsight>[];

    try {
      // Analyze steps trends
      if (stepsHistory.length >= 7) {
        final lastWeek = stepsHistory.take(7).toList();
        final previousWeek =
            stepsHistory.skip(7).take(7).toList();

        if (previousWeek.isNotEmpty) {
          final lastWeekAvg = _calculateAverageSteps(lastWeek);
          final previousWeekAvg = _calculateAverageSteps(previousWeek);

          if (lastWeekAvg > previousWeekAvg) {
            final improvement = ((lastWeekAvg - previousWeekAvg) /
                    previousWeekAvg *
                    100)
                .round();
            insights.add(
              HealthInsight(
                id: 'steps_improvement',
                title: 'Steps Improvement',
                message:
                    'Your average steps increased $improvement% this week!',
                createdAt: DateTime.now(),
                type: InsightType.improvement,
              ),
            );
          }
        }
      }

      // Analyze sleep patterns
      if (sleepHistory.length >= 7) {
        final weekdays = <double>[];
        final weekends = <double>[];

        for (final entry in sleepHistory.take(7)) {
          final weekday = entry.date.weekday;
          if (weekday >= 1 && weekday <= 5) {
            weekdays.add(entry.hours);
          } else {
            weekends.add(entry.hours);
          }
        }

        if (weekdays.isNotEmpty && weekends.isNotEmpty) {
          final weekdayAvg =
              weekdays.reduce((a, b) => a + b) / weekdays.length;
          final weekendAvg =
              weekends.reduce((a, b) => a + b) / weekends.length;

          if (weekendAvg > weekdayAvg + 0.5) {
            insights.add(
              HealthInsight(
                id: 'sleep_pattern',
                title: 'Sleep Pattern Detected',
                message:
                    'You sleep better on weekends. Consider maintaining consistent sleep schedule.',
                createdAt: DateTime.now(),
                type: InsightType.pattern,
              ),
            );
          }
        }
      }

      // Check for achievements
      final consecutiveDays = _checkConsecutiveGoalDays(
        stepsHistory,
        sleepHistory,
        waterHistory,
      );
      if (consecutiveDays >= 7) {
        insights.add(
          HealthInsight(
            id: 'goal_streak',
            title: 'Goal Achievement',
            message:
                'You\'ve met your health goals for $consecutiveDays days in a row! 🌟',
            createdAt: DateTime.now(),
            type: InsightType.achievement,
          ),
        );
      }
    } catch (e, stackTrace) {
      Logger.error(
        'HealthInsightsService: Error generating insights',
        error: e,
        stackTrace: stackTrace,
        feature: 'health_insights',
        screen: 'health_insights_service',
      );
    }

    return insights;
  }

  double _calculateAverageSteps(List<DailyStepsEntry> entries) {
    if (entries.isEmpty) return 0.0;
    final sum = entries.fold<int>(0, (sum, entry) => sum + entry.steps);
    return sum / entries.length;
  }

  int _checkConsecutiveGoalDays(
    List<DailyStepsEntry> stepsHistory,
    List<DailySleepEntry> sleepHistory,
    List<DailyWaterIntakeEntry> waterHistory,
  ) {
    // Simple check - can be enhanced with actual goals
    int consecutive = 0;
    final today = DateTime.now();
    
    for (int i = 0; i < 30; i++) {
      final date = today.subtract(Duration(days: i));
      final hasData = stepsHistory.any((e) =>
              e.date.year == date.year &&
              e.date.month == date.month &&
              e.date.day == date.day) ||
          sleepHistory.any((e) =>
              e.date.year == date.year &&
              e.date.month == date.month &&
              e.date.day == date.day) ||
          waterHistory.any((e) =>
              e.date.year == date.year &&
              e.date.month == date.month &&
              e.date.day == date.day);
      
      if (hasData) {
        consecutive++;
      } else {
        break;
      }
    }
    
    return consecutive;
  }
}

