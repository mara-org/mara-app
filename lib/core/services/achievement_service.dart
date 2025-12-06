import 'dart:convert';

import '../models/achievements/achievement.dart';
import '../models/health/daily_sleep_entry.dart';
import '../models/health/daily_steps_entry.dart';
import '../models/health/daily_water_intake_entry.dart';
import '../models/health/health_goals.dart';
import '../storage/local_cache.dart';
import '../utils/logger.dart';

/// Service for managing achievements and badges.
class AchievementService {
  static const String _achievementsKey = 'unlocked_achievements';

  /// All available achievements definitions.
  static final List<Achievement> _allAchievements = [
    const Achievement(
      id: 'first_steps',
      title: 'First Steps',
      description: 'Logged your first steps',
      iconName: 'directions_walk',
      type: AchievementType.firstSteps,
      category: AchievementCategory.steps,
    ),
    const Achievement(
      id: 'sleep_champion_7',
      title: 'Sleep Champion',
      description: '7 days of 8+ hours sleep',
      iconName: 'bedtime',
      type: AchievementType.sleepChampion,
      category: AchievementCategory.sleep,
    ),
    const Achievement(
      id: 'hydration_hero_30',
      title: 'Hydration Hero',
      description: 'Met water goal for 30 days in a row',
      iconName: 'water_drop',
      type: AchievementType.hydrationHero,
      category: AchievementCategory.water,
    ),
    const Achievement(
      id: 'goal_crusher_week',
      title: 'Goal Crusher',
      description: 'Met all goals for a week',
      iconName: 'emoji_events',
      type: AchievementType.goalCrusher,
      category: AchievementCategory.general,
    ),
  ];

  /// Check and unlock achievements based on health data.
  Future<List<Achievement>> checkAchievements({
    required List<DailyStepsEntry> stepsHistory,
    required List<DailySleepEntry> sleepHistory,
    required List<DailyWaterIntakeEntry> waterHistory,
    HealthGoals? goals,
  }) async {
    final unlocked = <Achievement>[];
    final alreadyUnlocked = await getUnlockedAchievements();

    try {
      // Check first steps achievement
      if (stepsHistory.isNotEmpty &&
          !alreadyUnlocked.any((a) => a.id == 'first_steps')) {
        unlocked.add(_allAchievements.firstWhere((a) => a.id == 'first_steps')
            .copyWith(unlockedAt: DateTime.now()));
      }

      // Check sleep champion (7 days of 8+ hours)
      if (sleepHistory.length >= 7) {
        final last7Days = sleepHistory.take(7).toList();
        final allMetGoal = last7Days.every((e) => e.hours >= 8.0);

        if (allMetGoal &&
            !alreadyUnlocked.any((a) => a.id == 'sleep_champion_7')) {
          unlocked.add(
            _allAchievements
                .firstWhere((a) => a.id == 'sleep_champion_7')
                .copyWith(unlockedAt: DateTime.now()),
          );
        }
      }

      // Check hydration hero (30 days in a row)
      if (waterHistory.length >= 30 && goals != null) {
        final last30Days = waterHistory.take(30).toList();
        final allMetGoal =
            last30Days.every((e) => e.waterLiters >= goals.dailyWaterGoal);

        if (allMetGoal &&
            !alreadyUnlocked.any((a) => a.id == 'hydration_hero_30')) {
          unlocked.add(
            _allAchievements
                .firstWhere((a) => a.id == 'hydration_hero_30')
                .copyWith(unlockedAt: DateTime.now()),
          );
        }
      }

      // Save newly unlocked achievements
      for (final achievement in unlocked) {
        await unlockAchievement(achievement);
      }
    } catch (e, stackTrace) {
      Logger.error(
        'AchievementService: Error checking achievements',
        error: e,
        stackTrace: stackTrace,
        feature: 'achievements',
        screen: 'achievement_service',
      );
    }

    return unlocked;
  }

  /// Get all unlocked achievements.
  Future<List<Achievement>> getUnlockedAchievements() async {
    try {
      await LocalCache.init();
      final jsonString = LocalCache.getString(_achievementsKey);

      if (jsonString == null) {
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => _achievementFromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      Logger.error(
        'AchievementService: Error loading achievements',
        error: e,
        stackTrace: stackTrace,
        feature: 'achievements',
        screen: 'achievement_service',
      );
      return [];
    }
  }

  /// Unlock an achievement.
  Future<bool> unlockAchievement(Achievement achievement) async {
    try {
      final unlocked = await getUnlockedAchievements();

      // Check if already unlocked
      if (unlocked.any((a) => a.id == achievement.id)) {
        return false;
      }

      // Add to unlocked list
      unlocked.add(achievement.copyWith(unlockedAt: DateTime.now()));

      // Save
      final jsonList = unlocked.map((a) => _achievementToJson(a)).toList();
      final jsonString = jsonEncode(jsonList);
      return await LocalCache.saveString(_achievementsKey, jsonString);
    } catch (e, stackTrace) {
      Logger.error(
        'AchievementService: Error unlocking achievement',
        error: e,
        stackTrace: stackTrace,
        feature: 'achievements',
        screen: 'achievement_service',
      );
      return false;
    }
  }

  /// Get all available achievements (locked and unlocked).
  Future<List<Achievement>> getAllAchievements() async {
    final unlocked = await getUnlockedAchievements();

    return _allAchievements.map((achievement) {
      return unlocked.firstWhere(
        (a) => a.id == achievement.id,
        orElse: () => achievement,
      );
    }).toList();
  }

  Map<String, dynamic> _achievementToJson(Achievement achievement) {
    return {
      'id': achievement.id,
      'title': achievement.title,
      'description': achievement.description,
      'iconName': achievement.iconName,
      'unlockedAt': achievement.unlockedAt?.toIso8601String(),
      'type': achievement.type.name,
      'category': achievement.category.name,
    };
  }

  Achievement _achievementFromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconName: json['iconName'] as String,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      type: AchievementType.values.firstWhere(
        (e) => e.name == json['type'] as String,
      ),
      category: AchievementCategory.values.firstWhere(
        (e) => e.name == json['category'] as String,
      ),
    );
  }
}

