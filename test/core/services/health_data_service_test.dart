// Unit tests for HealthDataService
// Tests health data service interface and implementation

import 'package:flutter_test/flutter_test.dart';
import 'package:mara_app/core/services/health_data_service.dart';

void main() {
  group('HealthDataService', () {
    late HealthDataService service;

    setUp(() {
      service = HealthDataService();
    });

    group('IHealthDataService interface', () {
      test('HealthDataService implements IHealthDataService', () {
        expect(service, isA<IHealthDataService>());
      });

      test('has requestPermissions method', () {
        expect(service.requestPermissions, isA<Future<bool> Function()>());
      });

      test('has hasPermissions method', () {
        expect(service.hasPermissions, isA<Future<bool> Function()>());
      });

      test('has getTodaySteps method', () {
        expect(service.getTodaySteps, isA<Future<int?> Function()>());
      });

      test('has getTodaySleepHours method', () {
        expect(service.getTodaySleepHours, isA<Future<double?> Function()>());
      });

      test('has getTodayWaterLiters method', () {
        expect(service.getTodayWaterLiters, isA<Future<double?> Function()>());
      });
    });

    group('requestPermissions', () {
      test('method exists and returns boolean', () async {
        final result = await service.requestPermissions();
        expect(result, isA<bool>());
      });
    });

    group('hasPermissions', () {
      test('method exists and returns boolean', () async {
        final result = await service.hasPermissions();
        expect(result, isA<bool>());
      });
    });

    group('getTodaySteps', () {
      test('method exists and returns nullable int', () async {
        final result = await service.getTodaySteps();
        // Result can be null if permissions not granted or data unavailable
        expect(result == null || result is int, isTrue);
      });
    });

    group('getTodaySleepHours', () {
      test('method exists and returns nullable double', () async {
        final result = await service.getTodaySleepHours();
        // Result can be null if permissions not granted or data unavailable
        expect(result == null || result is double, isTrue);
      });
    });

    group('getTodayWaterLiters', () {
      test('method exists and returns nullable double', () async {
        final result = await service.getTodayWaterLiters();
        // Result can be null if permissions not granted or data unavailable
        expect(result == null || result is double, isTrue);
      });
    });
  });

  group('IHealthDataService interface contract', () {
    test('interface defines all required methods', () {
      // Verify interface structure
      expect(IHealthDataService, isNotNull);

      // Verify methods exist on any implementation
      final service = HealthDataService();
      expect(service.requestPermissions, isA<Function>());
      expect(service.hasPermissions, isA<Function>());
      expect(service.getTodaySteps, isA<Function>());
      expect(service.getTodaySleepHours, isA<Function>());
      expect(service.getTodayWaterLiters, isA<Function>());
    });
  });
}
