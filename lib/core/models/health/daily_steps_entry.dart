/// Domain model representing daily steps entry.
///
/// This model represents a user's step count for a specific date.
/// All data processing happens locally on the device for maximum privacy.
class DailyStepsEntry {
  /// The date this entry represents (date only, time is ignored).
  final DateTime date;

  /// Number of steps taken on this date.
  final int steps;

  /// Timestamp when this entry was last updated (for sync purposes).
  final DateTime lastUpdatedAt;

  const DailyStepsEntry({
    required this.date,
    required this.steps,
    required this.lastUpdatedAt,
  });

  /// Validates if the steps entry is valid.
  bool get isValid {
    return steps >= 0 &&
        date.isBefore(DateTime.now().add(const Duration(days: 1)));
  }

  /// Creates a copy of this entry with updated fields.
  DailyStepsEntry copyWith({
    DateTime? date,
    int? steps,
    DateTime? lastUpdatedAt,
  }) {
    return DailyStepsEntry(
      date: date ?? this.date,
      steps: steps ?? this.steps,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  /// Creates a new entry for today with the given steps.
  factory DailyStepsEntry.today(int steps) {
    final now = DateTime.now();
    return DailyStepsEntry(
      date: DateTime(now.year, now.month, now.day),
      steps: steps,
      lastUpdatedAt: now,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyStepsEntry &&
          runtimeType == other.runtimeType &&
          date.year == other.date.year &&
          date.month == other.date.month &&
          date.day == other.date.day &&
          steps == other.steps;

  @override
  int get hashCode =>
      date.year.hashCode ^
      date.month.hashCode ^
      date.day.hashCode ^
      steps.hashCode;

  @override
  String toString() =>
      'DailyStepsEntry(date: $date, steps: $steps, lastUpdatedAt: $lastUpdatedAt)';
}
