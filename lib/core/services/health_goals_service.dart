import 'dart:convert';

import '../models/health/health_goals.dart';
import '../storage/local_cache.dart';
import '../utils/logger.dart';

/// Service for managing health goals.
///
/// Handles saving and loading health goals from local storage.
class HealthGoalsService {
  static const String _goalsKey = 'health_goals';

  /// Loads health goals from local storage.
  ///
  /// Returns default goals if none exist.
  Future<HealthGoals> loadGoals() async {
    try {
      await LocalCache.init();
      final jsonString = LocalCache.getString(_goalsKey);

      if (jsonString == null) {
        Logger.info(
          'HealthGoalsService: No saved goals found, returning defaults',
          feature: 'health_goals',
          screen: 'health_goals_service',
        );
        return HealthGoals.defaultGoals();
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final goals = HealthGoals.fromJson(json);

      if (!goals.isValid) {
        Logger.warning(
          'HealthGoalsService: Invalid goals found, returning defaults',
          feature: 'health_goals',
          screen: 'health_goals_service',
        );
        return HealthGoals.defaultGoals();
      }

      return goals;
    } catch (e, stackTrace) {
      Logger.error(
        'HealthGoalsService: Error loading goals',
        error: e,
        stackTrace: stackTrace,
        feature: 'health_goals',
        screen: 'health_goals_service',
      );
      return HealthGoals.defaultGoals();
    }
  }

  /// Saves health goals to local storage.
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> saveGoals(HealthGoals goals) async {
    try {
      if (!goals.isValid) {
        Logger.warning(
          'HealthGoalsService: Cannot save invalid goals',
          feature: 'health_goals',
          screen: 'health_goals_service',
        );
        return false;
      }

      await LocalCache.init();
      final jsonString = jsonEncode(goals.toJson());
      final saved = await LocalCache.saveString(_goalsKey, jsonString);

      if (saved) {
        Logger.info(
          'HealthGoalsService: Goals saved successfully',
          feature: 'health_goals',
          screen: 'health_goals_service',
        );
      }

      return saved;
    } catch (e, stackTrace) {
      Logger.error(
        'HealthGoalsService: Error saving goals',
        error: e,
        stackTrace: stackTrace,
        feature: 'health_goals',
        screen: 'health_goals_service',
      );
      return false;
    }
  }

  /// Resets goals to default values.
  Future<bool> resetGoals() async {
    return await saveGoals(HealthGoals.defaultGoals());
  }
}

