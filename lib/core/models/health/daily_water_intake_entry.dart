/// Domain model representing daily water intake entry.
///
/// This model represents a user's water consumption for a specific date.
/// All data processing happens locally on the device for maximum privacy.
class DailyWaterIntakeEntry {
  /// The date this entry represents (date only, time is ignored).
  final DateTime date;

  /// Water intake in liters for this date.
  final double waterLiters;

  /// Timestamp when this entry was last updated (for sync purposes).
  final DateTime lastUpdatedAt;

  const DailyWaterIntakeEntry({
    required this.date,
    required this.waterLiters,
    required this.lastUpdatedAt,
  });

  /// Validates if the water intake entry is valid.
  bool get isValid {
    return waterLiters >= 0 &&
        date.isBefore(DateTime.now().add(const Duration(days: 1)));
  }

  /// Creates a copy of this entry with updated fields.
  DailyWaterIntakeEntry copyWith({
    DateTime? date,
    double? waterLiters,
    DateTime? lastUpdatedAt,
  }) {
    return DailyWaterIntakeEntry(
      date: date ?? this.date,
      waterLiters: waterLiters ?? this.waterLiters,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  /// Creates a new entry for today with the given water liters.
  factory DailyWaterIntakeEntry.today(double waterLiters) {
    final now = DateTime.now();
    return DailyWaterIntakeEntry(
      date: DateTime(now.year, now.month, now.day),
      waterLiters: waterLiters,
      lastUpdatedAt: now,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyWaterIntakeEntry &&
          runtimeType == other.runtimeType &&
          date.year == other.date.year &&
          date.month == other.date.month &&
          date.day == other.date.day &&
          waterLiters == other.waterLiters;

  @override
  int get hashCode =>
      date.year.hashCode ^
      date.month.hashCode ^
      date.day.hashCode ^
      waterLiters.hashCode;

  @override
  String toString() =>
      'DailyWaterIntakeEntry(date: $date, waterLiters: $waterLiters, lastUpdatedAt: $lastUpdatedAt)';
}
