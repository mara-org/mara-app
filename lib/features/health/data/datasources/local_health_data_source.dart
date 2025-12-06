import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../../core/models/health/daily_sleep_entry.dart';
import '../../../../core/models/health/daily_steps_entry.dart';
import '../../../../core/models/health/daily_water_intake_entry.dart';
import '../../../../core/storage/local_cache.dart';

/// Local data source for health tracking data.
///
/// Stores health entries in local cache using JSON serialization.
/// Keys are formatted as: "health_steps_YYYY-MM-DD", "health_sleep_YYYY-MM-DD", etc.
class LocalHealthDataSource {
  static const String _stepsPrefix = 'health_steps_';
  static const String _sleepPrefix = 'health_sleep_';
  static const String _waterPrefix = 'health_water_';
  static const String _stepsListKey = 'health_steps_list';
  static const String _sleepListKey = 'health_sleep_list';
  static const String _waterListKey = 'health_water_list';

  /// Gets today's steps entry.
  Future<DailyStepsEntry?> getTodaySteps() async {
    return getStepsEntry(_getTodayDateString());
  }

  /// Gets steps entry for a specific date.
  ///
  /// [dateString] - Date string in YYYY-MM-DD format.
  Future<DailyStepsEntry?> getStepsEntry(String dateString) async {
    final key = '$_stepsPrefix$dateString';
    final jsonString = LocalCache.getString(key);
    if (jsonString == null) {
      return null;
    }
    try {
      return _stepsEntryFromJson(json.decode(jsonString) as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to parse steps entry: $e');
      }
      return null;
    }
  }

  /// Saves a steps entry.
  Future<void> saveStepsEntry(DailyStepsEntry entry) async {
    final dateString = _dateToString(entry.date);
    final key = '$_stepsPrefix$dateString';
    final jsonMap = _stepsEntryToJson(entry);
    await LocalCache.saveString(key, json.encode(jsonMap));

    // Update the list of dates
    await _addDateToList(_stepsListKey, dateString);
  }

  /// Gets today's sleep entry.
  Future<DailySleepEntry?> getTodaySleep() async {
    return getSleepEntry(_getTodayDateString());
  }

  /// Gets sleep entry for a specific date.
  Future<DailySleepEntry?> getSleepEntry(String dateString) async {
    final key = '$_sleepPrefix$dateString';
    final jsonString = LocalCache.getString(key);
    if (jsonString == null) {
      return null;
    }
    try {
      return _sleepEntryFromJson(json.decode(jsonString) as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to parse sleep entry: $e');
      }
      return null;
    }
  }

  /// Saves a sleep entry.
  Future<void> saveSleepEntry(DailySleepEntry entry) async {
    final dateString = _dateToString(entry.date);
    final key = '$_sleepPrefix$dateString';
    final jsonMap = _sleepEntryToJson(entry);
    await LocalCache.saveString(key, json.encode(jsonMap));

    // Update the list of dates
    await _addDateToList(_sleepListKey, dateString);
  }

  /// Gets today's water intake entry.
  Future<DailyWaterIntakeEntry?> getTodayWater() async {
    return getWaterEntry(_getTodayDateString());
  }

  /// Gets water entry for a specific date.
  Future<DailyWaterIntakeEntry?> getWaterEntry(String dateString) async {
    final key = '$_waterPrefix$dateString';
    final jsonString = LocalCache.getString(key);
    if (jsonString == null) {
      return null;
    }
    try {
      return _waterEntryFromJson(json.decode(jsonString) as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to parse water entry: $e');
      }
      return null;
    }
  }

  /// Saves a water intake entry.
  Future<void> saveWaterIntakeEntry(DailyWaterIntakeEntry entry) async {
    final dateString = _dateToString(entry.date);
    final key = '$_waterPrefix$dateString';
    final jsonMap = _waterEntryToJson(entry);
    await LocalCache.saveString(key, json.encode(jsonMap));

    // Update the list of dates
    await _addDateToList(_waterListKey, dateString);
  }

  /// Gets all steps entries, sorted by date (most recent first).
  Future<List<DailyStepsEntry>> getStepsHistory({int? limit}) async {
    final dateStrings = await _getDateList(_stepsListKey);
    final entries = <DailyStepsEntry>[];

    for (final dateString in dateStrings) {
      final entry = await getStepsEntry(dateString);
      if (entry != null) {
        entries.add(entry);
      }
    }

    // Sort by date (most recent first)
    entries.sort((a, b) => b.date.compareTo(a.date));

    if (limit != null && limit > 0) {
      return entries.take(limit).toList();
    }
    return entries;
  }

  /// Gets all sleep entries, sorted by date (most recent first).
  Future<List<DailySleepEntry>> getSleepHistory({int? limit}) async {
    final dateStrings = await _getDateList(_sleepListKey);
    final entries = <DailySleepEntry>[];

    for (final dateString in dateStrings) {
      final entry = await getSleepEntry(dateString);
      if (entry != null) {
        entries.add(entry);
      }
    }

    // Sort by date (most recent first)
    entries.sort((a, b) => b.date.compareTo(a.date));

    if (limit != null && limit > 0) {
      return entries.take(limit).toList();
    }
    return entries;
  }

  /// Gets all water intake entries, sorted by date (most recent first).
  Future<List<DailyWaterIntakeEntry>> getWaterHistory({int? limit}) async {
    final dateStrings = await _getDateList(_waterListKey);
    final entries = <DailyWaterIntakeEntry>[];

    for (final dateString in dateStrings) {
      final entry = await getWaterEntry(dateString);
      if (entry != null) {
        entries.add(entry);
      }
    }

    // Sort by date (most recent first)
    entries.sort((a, b) => b.date.compareTo(a.date));

    if (limit != null && limit > 0) {
      return entries.take(limit).toList();
    }
    return entries;
  }

  // Private helper methods

  String _getTodayDateString() {
    return _dateToString(DateTime.now());
  }

  String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime _stringToDate(String dateString) {
    final parts = dateString.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  Future<void> _addDateToList(String listKey, String dateString) async {
    final existing = await _getDateList(listKey);
    if (!existing.contains(dateString)) {
      existing.add(dateString);
      await LocalCache.saveString(listKey, json.encode(existing));
    }
  }

  Future<List<String>> _getDateList(String listKey) async {
    final jsonString = LocalCache.getString(listKey);
    if (jsonString == null) {
      return [];
    }
    try {
      final list = json.decode(jsonString) as List<dynamic>;
      return list.map((e) => e.toString()).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to parse date list: $e');
      }
      return [];
    }
  }

  // JSON serialization methods

  Map<String, dynamic> _stepsEntryToJson(DailyStepsEntry entry) {
    return {
      'date': _dateToString(entry.date),
      'steps': entry.steps,
      'lastUpdatedAt': entry.lastUpdatedAt.toIso8601String(),
    };
  }

  DailyStepsEntry _stepsEntryFromJson(Map<String, dynamic> json) {
    return DailyStepsEntry(
      date: _stringToDate(json['date'] as String),
      steps: json['steps'] as int,
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
    );
  }

  Map<String, dynamic> _sleepEntryToJson(DailySleepEntry entry) {
    return {
      'date': _dateToString(entry.date),
      'hours': entry.hours,
      'lastUpdatedAt': entry.lastUpdatedAt.toIso8601String(),
    };
  }

  DailySleepEntry _sleepEntryFromJson(Map<String, dynamic> json) {
    return DailySleepEntry(
      date: _stringToDate(json['date'] as String),
      hours: (json['hours'] as num).toDouble(),
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
    );
  }

  Map<String, dynamic> _waterEntryToJson(DailyWaterIntakeEntry entry) {
    return {
      'date': _dateToString(entry.date),
      'waterLiters': entry.waterLiters,
      'lastUpdatedAt': entry.lastUpdatedAt.toIso8601String(),
    };
  }

  DailyWaterIntakeEntry _waterEntryFromJson(Map<String, dynamic> json) {
    return DailyWaterIntakeEntry(
      date: _stringToDate(json['date'] as String),
      waterLiters: (json['waterLiters'] as num).toDouble(),
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
    );
  }
}

