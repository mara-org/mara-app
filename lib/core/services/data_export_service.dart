import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

import '../models/health/daily_sleep_entry.dart';
import '../models/health/daily_steps_entry.dart';
import '../models/health/daily_water_intake_entry.dart';
import '../utils/logger.dart';

/// Format for data export.
enum ExportFormat { json, csv }

/// Service for exporting health data locally.
class DataExportService {
  /// Export health data to a file.
  ///
  /// Returns the file path if successful, null otherwise.
  Future<String?> exportHealthData({
    required List<DailyStepsEntry> stepsHistory,
    required List<DailySleepEntry> sleepHistory,
    required List<DailyWaterIntakeEntry> waterHistory,
    required ExportFormat format,
    String? fileName,
  }) async {
    try {
      final directory = await _getExportDirectory();
      if (directory == null) {
        return null;
      }

      final extension = format == ExportFormat.json ? 'json' : 'csv';
      final name = fileName ??
          'mara_health_data_${DateTime.now().millisecondsSinceEpoch}';
      final file = File('${directory.path}/$name.$extension');

      String content;
      if (format == ExportFormat.json) {
        content = _exportAsJson(
          stepsHistory: stepsHistory,
          sleepHistory: sleepHistory,
          waterHistory: waterHistory,
        );
      } else {
        content = _exportAsCsv(
          stepsHistory: stepsHistory,
          sleepHistory: sleepHistory,
          waterHistory: waterHistory,
        );
      }

      await file.writeAsString(content);
      return file.path;
    } catch (e, stackTrace) {
      Logger.error(
        'DataExportService: Error exporting data',
        error: e,
        stackTrace: stackTrace,
        feature: 'data_export',
        screen: 'data_export_service',
      );
      return null;
    }
  }

  Future<Directory?> _getExportDirectory() async {
    try {
      if (Platform.isAndroid) {
        final directory = await getExternalStorageDirectory();
        return directory;
      } else if (Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        return Directory('${directory.path}/exports')
          ..createSync(recursive: true);
      }
      return null;
    } catch (e, stackTrace) {
      Logger.error(
        'DataExportService: Error getting export directory',
        error: e,
        stackTrace: stackTrace,
        feature: 'data_export',
        screen: 'data_export_service',
      );
      return null;
    }
  }

  String _exportAsJson({
    required List<DailyStepsEntry> stepsHistory,
    required List<DailySleepEntry> sleepHistory,
    required List<DailyWaterIntakeEntry> waterHistory,
  }) {
    final data = {
      'exportDate': DateTime.now().toIso8601String(),
      'steps': stepsHistory
          .map((e) => {
                'date': e.date.toIso8601String(),
                'steps': e.steps,
                'lastUpdatedAt': e.lastUpdatedAt.toIso8601String(),
              })
          .toList(),
      'sleep': sleepHistory
          .map((e) => {
                'date': e.date.toIso8601String(),
                'hours': e.hours,
                'lastUpdatedAt': e.lastUpdatedAt.toIso8601String(),
              })
          .toList(),
      'water': waterHistory
          .map((e) => {
                'date': e.date.toIso8601String(),
                'waterLiters': e.waterLiters,
                'lastUpdatedAt': e.lastUpdatedAt.toIso8601String(),
              })
          .toList(),
    };

    return JsonEncoder.withIndent('  ').convert(data);
  }

  String _exportAsCsv({
    required List<DailyStepsEntry> stepsHistory,
    required List<DailySleepEntry> sleepHistory,
    required List<DailyWaterIntakeEntry> waterHistory,
  }) {
    final rows = <List<dynamic>>[];

    // Header
    rows.add(['Date', 'Steps', 'Sleep (hours)', 'Water (liters)']);

    // Collect all dates
    final allDates = <DateTime>{};
    for (final e in stepsHistory) {
      allDates.add(DateTime(e.date.year, e.date.month, e.date.day));
    }
    for (final e in sleepHistory) {
      allDates.add(DateTime(e.date.year, e.date.month, e.date.day));
    }
    for (final e in waterHistory) {
      allDates.add(DateTime(e.date.year, e.date.month, e.date.day));
    }

    // Sort dates
    final sortedDates = allDates.toList()..sort((a, b) => b.compareTo(a));

    // Create rows
    for (final date in sortedDates) {
      final steps = stepsHistory.firstWhere(
        (e) =>
            e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day,
        orElse: () => DailyStepsEntry(
          date: date,
          steps: 0,
          lastUpdatedAt: date,
        ),
      );

      final sleep = sleepHistory.firstWhere(
        (e) =>
            e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day,
        orElse: () => DailySleepEntry(
          date: date,
          hours: 0.0,
          lastUpdatedAt: date,
        ),
      );

      final water = waterHistory.firstWhere(
        (e) =>
            e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day,
        orElse: () => DailyWaterIntakeEntry(
          date: date,
          waterLiters: 0.0,
          lastUpdatedAt: date,
        ),
      );

      rows.add([
        date.toIso8601String().split('T')[0],
        steps.steps,
        sleep.hours,
        water.waterLiters,
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }
}
