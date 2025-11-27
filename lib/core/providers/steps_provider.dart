import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for daily step count
/// TODO: Connect to HealthKit (iOS) or Google Fit (Android) for actual step data
final stepsProvider = StateProvider<int>((ref) {
  // Placeholder: Returns 0 if no data available
  // In production, this should fetch from HealthKit/Google Fit
  return 0;
});

/// Provider for daily step goal (default 10,000)
final stepsGoalProvider = StateProvider<int>((ref) {
  return 10000;
});

