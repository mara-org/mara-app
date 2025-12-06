/// Domain model representing daily sleep entry.
///
/// This model represents a user's sleep duration for a specific date.
/// All data processing happens locally on the device for maximum privacy.
class DailySleepEntry {
  /// The date this entry represents (date only, time is ignored).
  final DateTime date;

  /// Number of hours slept on this date.
  final double hours;

  /// Timestamp when this entry was last updated (for sync purposes).
  final DateTime lastUpdatedAt;

  const DailySleepEntry({
    required this.date,
    required this.hours,
    required this.lastUpdatedAt,
  });

  /// Validates if the sleep entry is valid.
  bool get isValid {
    return hours >= 0 && hours <= 24 && date.isBefore(DateTime.now().add(const Duration(days: 1)));
  }

  /// Creates a copy of this entry with updated fields.
  DailySleepEntry copyWith({
    DateTime? date,
    double? hours,
    DateTime? lastUpdatedAt,
  }) {
    return DailySleepEntry(
      date: date ?? this.date,
      hours: hours ?? this.hours,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  /// Creates a new entry for today with the given hours.
  factory DailySleepEntry.today(double hours) {
    final now = DateTime.now();
    return DailySleepEntry(
      date: DateTime(now.year, now.month, now.day),
      hours: hours,
      lastUpdatedAt: now,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailySleepEntry &&
          runtimeType == other.runtimeType &&
          date.year == other.date.year &&
          date.month == other.date.month &&
          date.day == other.date.day &&
          hours == other.hours;

  @override
  int get hashCode =>
      date.year.hashCode ^ date.month.hashCode ^ date.day.hashCode ^ hours.hashCode;

  @override
  String toString() => 'DailySleepEntry(date: $date, hours: $hours, lastUpdatedAt: $lastUpdatedAt)';
}

