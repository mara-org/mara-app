import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/health/health_goals.dart';
import '../services/health_goals_service.dart';

/// Provider for [HealthGoalsService].
final healthGoalsServiceProvider = Provider<HealthGoalsService>((ref) {
  return HealthGoalsService();
});

/// Provider for health goals.
///
/// This provider loads goals from local storage and provides reactive updates.
final healthGoalsProvider = FutureProvider<HealthGoals>((ref) async {
  final service = ref.read(healthGoalsServiceProvider);
  return await service.loadGoals();
});

/// Provider for updating health goals.
///
/// Use this to update goals and refresh the provider.
final updateHealthGoalsProvider = FutureProvider.family<bool, HealthGoals>(
  (ref, goals) async {
    final service = ref.read(healthGoalsServiceProvider);
    final saved = await service.saveGoals(goals);

    if (saved) {
      // Invalidate the goals provider to trigger a refresh
      ref.invalidate(healthGoalsProvider);
    }

    return saved;
  },
);

