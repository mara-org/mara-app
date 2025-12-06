// Unit tests for HealthTrackingRepository
// Tests repository layer operations for health tracking

import 'package:flutter_test/flutter_test.dart';
import 'package:mara_app/core/models/health/daily_sleep_entry.dart';
import 'package:mara_app/core/models/health/daily_steps_entry.dart';
import 'package:mara_app/core/models/health/daily_water_intake_entry.dart';
import 'package:mara_app/features/health/data/datasources/local_health_data_source.dart';
import 'package:mara_app/features/health/data/repositories/health_tracking_repository_impl.dart';

void main() {
  group('HealthTrackingRepositoryImpl', () {
    late LocalHealthDataSource localDataSource;
    late HealthTrackingRepositoryImpl repository;

    setUp(() {
      localDataSource = LocalHealthDataSource();
      repository = HealthTrackingRepositoryImpl(localDataSource);
    });

    group('Steps Operations', () {
      test('getTodaySteps retrieves today\'s steps', () async {
        final entry = DailyStepsEntry.today(steps: 5000);
        await localDataSource.saveStepsEntry(entry);

        final result = await repository.getTodaySteps();
        expect(result, isNotNull);
        expect(result?.steps, equals(5000));
      });

      test('saveStepsEntry saves steps entry', () async {
        final entry = DailyStepsEntry.today(steps: 6000);
        await repository.saveStepsEntry(entry);

        final retrieved = await repository.getTodaySteps();
        expect(retrieved?.steps, equals(6000));
      });

      test('getStepsHistory retrieves history', () async {
        final entry = DailyStepsEntry.today(steps: 5000);
        await repository.saveStepsEntry(entry);

        final history = await repository.getStepsHistory();
        expect(history, isNotEmpty);
      });
    });

    group('Sleep Operations', () {
      test('getTodaySleep retrieves today\'s sleep', () async {
        final entry = DailySleepEntry.today(hours: 8.0);
        await localDataSource.saveSleepEntry(entry);

        final result = await repository.getTodaySleep();
        expect(result, isNotNull);
        expect(result?.hours, equals(8.0));
      });

      test('saveSleepEntry saves sleep entry', () async {
        final entry = DailySleepEntry.today(hours: 7.5);
        await repository.saveSleepEntry(entry);

        final retrieved = await repository.getTodaySleep();
        expect(retrieved?.hours, equals(7.5));
      });

      test('getSleepHistory retrieves history', () async {
        final entry = DailySleepEntry.today(hours: 8.0);
        await repository.saveSleepEntry(entry);

        final history = await repository.getSleepHistory();
        expect(history, isNotEmpty);
      });
    });

    group('Water Operations', () {
      test('getTodayWater retrieves today\'s water', () async {
        final entry = DailyWaterIntakeEntry.today(waterLiters: 2.5);
        await localDataSource.saveWaterIntakeEntry(entry);

        final result = await repository.getTodayWater();
        expect(result, isNotNull);
        expect(result?.waterLiters, equals(2.5));
      });

      test('saveWaterIntakeEntry saves water entry', () async {
        final entry = DailyWaterIntakeEntry.today(waterLiters: 3.0);
        await repository.saveWaterIntakeEntry(entry);

        final retrieved = await repository.getTodayWater();
        expect(retrieved?.waterLiters, equals(3.0));
      });

      test('getWaterHistory retrieves history', () async {
        final entry = DailyWaterIntakeEntry.today(waterLiters: 2.5);
        await repository.saveWaterIntakeEntry(entry);

        final history = await repository.getWaterHistory();
        expect(history, isNotEmpty);
      });
    });

    group('syncWithRemoteStub', () {
      test('syncWithRemoteStub is a no-op', () async {
        // Should not throw
        await repository.syncWithRemoteStub();
        expect(true, isTrue);
      });
    });
  });
}
