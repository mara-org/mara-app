// Unit tests for LocalHealthDataSource
// Tests local storage operations for health tracking data

import 'package:flutter_test/flutter_test.dart';
import 'package:mara_app/core/models/health/daily_sleep_entry.dart';
import 'package:mara_app/core/models/health/daily_steps_entry.dart';
import 'package:mara_app/core/models/health/daily_water_intake_entry.dart';
import 'package:mara_app/features/health/data/datasources/local_health_data_source.dart';
import 'package:mara_app/core/storage/local_cache.dart';

void main() {
  group('LocalHealthDataSource', () {
    late LocalHealthDataSource dataSource;

    setUp(() {
      dataSource = LocalHealthDataSource();
      // Clear any existing data before each test
      // Note: In a real scenario, we'd use a test-specific storage
    });

    group('Steps Entry Operations', () {
      test('saveStepsEntry and getStepsEntry work correctly', () async {
        final entry = DailyStepsEntry.today(steps: 5000);
        await dataSource.saveStepsEntry(entry);

        final retrieved = await dataSource.getStepsEntry(DateTime.now());
        expect(retrieved, isNotNull);
        expect(retrieved?.steps, equals(5000));
        expect(retrieved?.date.day, equals(DateTime.now().day));
        expect(retrieved?.date.month, equals(DateTime.now().month));
        expect(retrieved?.date.year, equals(DateTime.now().year));
      });

      test('getStepsEntry returns null for non-existent entry', () async {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final retrieved = await dataSource.getStepsEntry(yesterday);
        expect(retrieved, isNull);
      });

      test('saveStepsEntry updates existing entry', () async {
        final entry1 = DailyStepsEntry.today(steps: 5000);
        await dataSource.saveStepsEntry(entry1);

        final entry2 = DailyStepsEntry.today(steps: 7000);
        await dataSource.saveStepsEntry(entry2);

        final retrieved = await dataSource.getStepsEntry(DateTime.now());
        expect(retrieved?.steps, equals(7000));
      });
    });

    group('Sleep Entry Operations', () {
      test('saveSleepEntry and getSleepEntry work correctly', () async {
        final entry = DailySleepEntry.today(hours: 7.5);
        await dataSource.saveSleepEntry(entry);

        final retrieved = await dataSource.getSleepEntry(DateTime.now());
        expect(retrieved, isNotNull);
        expect(retrieved?.hours, equals(7.5));
      });

      test('getSleepEntry returns null for non-existent entry', () async {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final retrieved = await dataSource.getSleepEntry(yesterday);
        expect(retrieved, isNull);
      });
    });

    group('Water Intake Entry Operations', () {
      test('saveWaterIntakeEntry and getWaterIntakeEntry work correctly', () async {
        final entry = DailyWaterIntakeEntry.today(waterLiters: 2.5);
        await dataSource.saveWaterIntakeEntry(entry);

        final retrieved = await dataSource.getWaterIntakeEntry(DateTime.now());
        expect(retrieved, isNotNull);
        expect(retrieved?.waterLiters, equals(2.5));
      });

      test('getWaterIntakeEntry returns null for non-existent entry', () async {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final retrieved = await dataSource.getWaterIntakeEntry(yesterday);
        expect(retrieved, isNull);
      });
    });

    group('History Operations', () {
      test('getStepsHistory returns all entries sorted by date', () async {
        // Create entries for different dates
        final today = DailyStepsEntry.today(steps: 5000);
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
        expect(history.first.date.isAfter(history.last.date) ||
            history.first.date.isAtSameMomentAs(history.last.date), isTrue);
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
        final entry = DailySleepEntry.today(hours: 8.0);
        await dataSource.saveSleepEntry(entry);

        final history = await dataSource.getSleepHistory();
        expect(history.length, greaterThanOrEqualTo(1));
        expect(history.first.hours, equals(8.0));
      });

      test('getWaterHistory returns all entries', () async {
        final entry = DailyWaterIntakeEntry.today(waterLiters: 2.0);
        await dataSource.saveWaterIntakeEntry(entry);

        final history = await dataSource.getWaterHistory();
        expect(history.length, greaterThanOrEqualTo(1));
        expect(history.first.waterLiters, equals(2.0));
      });
    });

    group('Today Operations', () {
      test('getTodaySteps returns today\'s entry', () async {
        final entry = DailyStepsEntry.today(steps: 6000);
        await dataSource.saveStepsEntry(entry);

        final todayEntry = await dataSource.getTodaySteps();
        expect(todayEntry, isNotNull);
        expect(todayEntry?.steps, equals(6000));
      });

      test('getTodaySleep returns today\'s entry', () async {
        final entry = DailySleepEntry.today(hours: 7.0);
        await dataSource.saveSleepEntry(entry);

        final todayEntry = await dataSource.getTodaySleep();
        expect(todayEntry, isNotNull);
        expect(todayEntry?.hours, equals(7.0));
      });

      test('getTodayWater returns today\'s entry', () async {
        final entry = DailyWaterIntakeEntry.today(waterLiters: 3.0);
        await dataSource.saveWaterIntakeEntry(entry);

        final todayEntry = await dataSource.getTodayWater();
        expect(todayEntry, isNotNull);
        expect(todayEntry?.waterLiters, equals(3.0));
      });
    });
  });
}

