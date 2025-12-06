// Unit tests for LocalHealthDataSource
// Tests local storage operations for health tracking data

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mara_app/core/models/health/daily_sleep_entry.dart';
import 'package:mara_app/core/models/health/daily_steps_entry.dart';
import 'package:mara_app/core/models/health/daily_water_intake_entry.dart';
import 'package:mara_app/features/health/data/datasources/local_health_data_source.dart';
import 'package:mara_app/core/storage/local_cache.dart';

void main() {
  group('LocalHealthDataSource', () {
    late LocalHealthDataSource dataSource;

    setUp(() async {
      // Initialize SharedPreferences with empty mock data
      SharedPreferences.setMockInitialValues({});
      // Initialize LocalCache
      await LocalCache.init();
      // Clear cache before each test
      await LocalCache.clear();
      dataSource = LocalHealthDataSource();
    });

    group('Steps Entry Operations', () {
      String _dateToString(DateTime date) {
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }

      test('saveStepsEntry and getStepsEntry work correctly', () async {
        final entry = DailyStepsEntry.today(5000);
        await dataSource.saveStepsEntry(entry);

        final now = DateTime.now();
        final dateString = _dateToString(now);
        final retrieved = await dataSource.getStepsEntry(dateString);
        expect(retrieved, isNotNull);
        expect(retrieved?.steps, equals(5000));
        expect(retrieved?.date.day, equals(now.day));
        expect(retrieved?.date.month, equals(now.month));
        expect(retrieved?.date.year, equals(now.year));
      });

      test('getStepsEntry returns null for non-existent entry', () async {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final dateString = _dateToString(yesterday);
        final retrieved = await dataSource.getStepsEntry(dateString);
        expect(retrieved, isNull);
      });

      test('saveStepsEntry updates existing entry', () async {
        final entry1 = DailyStepsEntry.today(5000);
        await dataSource.saveStepsEntry(entry1);

        final entry2 = DailyStepsEntry.today(7000);
        await dataSource.saveStepsEntry(entry2);

        final now = DateTime.now();
        final dateString = _dateToString(now);
        final retrieved = await dataSource.getStepsEntry(dateString);
        expect(retrieved?.steps, equals(7000));
      });
    });

    group('Sleep Entry Operations', () {
      String _dateToString(DateTime date) {
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }

      test('saveSleepEntry and getSleepEntry work correctly', () async {
        final entry = DailySleepEntry.today(7.5);
        await dataSource.saveSleepEntry(entry);

        final now = DateTime.now();
        final dateString = _dateToString(now);
        final retrieved = await dataSource.getSleepEntry(dateString);
        expect(retrieved, isNotNull);
        expect(retrieved?.hours, equals(7.5));
      });

      test('getSleepEntry returns null for non-existent entry', () async {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final dateString = _dateToString(yesterday);
        final retrieved = await dataSource.getSleepEntry(dateString);
        expect(retrieved, isNull);
      });
    });

    group('Water Intake Entry Operations', () {
      String _dateToString(DateTime date) {
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }

      test('saveWaterIntakeEntry and getWaterEntry work correctly', () async {
        final entry = DailyWaterIntakeEntry.today(2.5);
        await dataSource.saveWaterIntakeEntry(entry);

        final now = DateTime.now();
        final dateString = _dateToString(now);
        final retrieved = await dataSource.getWaterEntry(dateString);
        expect(retrieved, isNotNull);
        expect(retrieved?.waterLiters, equals(2.5));
      });

      test('getWaterEntry returns null for non-existent entry', () async {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final dateString = _dateToString(yesterday);
        final retrieved = await dataSource.getWaterEntry(dateString);
        expect(retrieved, isNull);
      });
    });

    group('History Operations', () {
      test('getStepsHistory returns all entries sorted by date', () async {
        // Create entries for different dates
        final today = DailyStepsEntry.today(5000);
        final yesterday = DailyStepsEntry(
          date: DateTime.now().subtract(const Duration(days: 1)),
          steps: 3000,
          lastUpdatedAt: DateTime.now(),
        );

        await dataSource.saveStepsEntry(yesterday);
        await dataSource.saveStepsEntry(today);

        final history = await dataSource.getStepsHistory();
        expect(history.length, greaterThanOrEqualTo(2));
        // Should be sorted by date (most recent first)
        expect(
            history.first.date.isAfter(history.last.date) ||
                history.first.date.isAtSameMomentAs(history.last.date),
            isTrue);
      });

      test('getStepsHistory respects limit parameter', () async {
        // Create multiple entries
        for (int i = 0; i < 5; i++) {
          final entry = DailyStepsEntry(
            date: DateTime.now().subtract(Duration(days: i)),
            steps: 1000 * i,
            lastUpdatedAt: DateTime.now(),
          );
          await dataSource.saveStepsEntry(entry);
        }

        final history = await dataSource.getStepsHistory(limit: 3);
        expect(history.length, lessThanOrEqualTo(3));
      });

      test('getSleepHistory returns all entries', () async {
        final entry = DailySleepEntry.today(8.0);
        await dataSource.saveSleepEntry(entry);

        final history = await dataSource.getSleepHistory();
        expect(history.length, greaterThanOrEqualTo(1));
        expect(history.first.hours, equals(8.0));
      });

      test('getWaterHistory returns all entries', () async {
        final entry = DailyWaterIntakeEntry.today(2.0);
        await dataSource.saveWaterIntakeEntry(entry);

        final history = await dataSource.getWaterHistory();
        expect(history.length, greaterThanOrEqualTo(1));
        expect(history.first.waterLiters, equals(2.0));
      });
    });

    group('Today Operations', () {
      test('getTodaySteps returns today\'s entry', () async {
        final entry = DailyStepsEntry.today(6000);
        await dataSource.saveStepsEntry(entry);

        final todayEntry = await dataSource.getTodaySteps();
        expect(todayEntry, isNotNull);
        expect(todayEntry?.steps, equals(6000));
      });

      test('getTodaySleep returns today\'s entry', () async {
        final entry = DailySleepEntry.today(7.0);
        await dataSource.saveSleepEntry(entry);

        final todayEntry = await dataSource.getTodaySleep();
        expect(todayEntry, isNotNull);
        expect(todayEntry?.hours, equals(7.0));
      });

      test('getTodayWater returns today\'s entry', () async {
        final entry = DailyWaterIntakeEntry.today(3.0);
        await dataSource.saveWaterIntakeEntry(entry);

        final todayEntry = await dataSource.getTodayWater();
        expect(todayEntry, isNotNull);
        expect(todayEntry?.waterLiters, equals(3.0));
      });
    });
  });
}
