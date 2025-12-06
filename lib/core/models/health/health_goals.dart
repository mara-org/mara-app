/// Domain model representing user's health goals.
///
/// This model represents daily goals for steps, sleep, and water intake.
/// All goals are stored locally and used to track progress.
class HealthGoals {
  /// Daily steps goal (default: 10,000 steps).
  final int dailyStepsGoal;

  /// Daily sleep goal in hours (default: 8.0 hours).
  final double dailySleepGoal;

  /// Daily water intake goal in liters (default: 2.5 liters).
  final double dailyWaterGoal;

  /// Timestamp when goals were last updated.
  final DateTime lastUpdatedAt;

  const HealthGoals({
    this.dailyStepsGoal = 10000,
    this.dailySleepGoal = 8.0,
    this.dailyWaterGoal = 2.5,
    required this.lastUpdatedAt,
  });

  /// Creates default health goals.
  factory HealthGoals.defaultGoals() {
    return HealthGoals(
      dailyStepsGoal: 10000,
      dailySleepGoal: 8.0,
      dailyWaterGoal: 2.5,
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// Validates if the goals are valid.
  bool get isValid {
    return dailyStepsGoal > 0 &&
        dailyStepsGoal <= 100000 &&
        dailySleepGoal > 0 &&
        dailySleepGoal <= 24.0 &&
        dailyWaterGoal > 0 &&
        dailyWaterGoal <= 20.0;
  }

  /// Creates a copy of this goals object with updated fields.
  HealthGoals copyWith({
    int? dailyStepsGoal,
    double? dailySleepGoal,
    double? dailyWaterGoal,
    DateTime? lastUpdatedAt,
  }) {
    return HealthGoals(
      dailyStepsGoal: dailyStepsGoal ?? this.dailyStepsGoal,
      dailySleepGoal: dailySleepGoal ?? this.dailySleepGoal,
      dailyWaterGoal: dailyWaterGoal ?? this.dailyWaterGoal,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  /// Converts goals to JSON for storage.
  Map<String, dynamic> toJson() {
    return {
      'dailyStepsGoal': dailyStepsGoal,
      'dailySleepGoal': dailySleepGoal,
      'dailyWaterGoal': dailyWaterGoal,
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
    };
  }

  /// Creates goals from JSON.
  factory HealthGoals.fromJson(Map<String, dynamic> json) {
    return HealthGoals(
      dailyStepsGoal: json['dailyStepsGoal'] as int? ?? 10000,
      dailySleepGoal: (json['dailySleepGoal'] as num?)?.toDouble() ?? 8.0,
      dailyWaterGoal: (json['dailyWaterGoal'] as num?)?.toDouble() ?? 2.5,
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthGoals &&
          runtimeType == other.runtimeType &&
          dailyStepsGoal == other.dailyStepsGoal &&
          dailySleepGoal == other.dailySleepGoal &&
          dailyWaterGoal == other.dailyWaterGoal;

  @override
  int get hashCode =>
      dailyStepsGoal.hashCode ^
      dailySleepGoal.hashCode ^
      dailyWaterGoal.hashCode;

  @override
  String toString() =>
      'HealthGoals(steps: $dailyStepsGoal, sleep: ${dailySleepGoal}h, water: ${dailyWaterGoal}L)';
}
