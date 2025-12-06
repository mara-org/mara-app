import 'dart:io';

import 'package:health/health.dart';
import '../../core/utils/logger.dart';

/// Helper class for DateTime range operations
class _DateTimeRange {
  final DateTime start;
  final DateTime end;

  _DateTimeRange({required this.start, required this.end});

  Duration get duration => end.difference(start);
}

/// Abstract interface for health data services.
///
/// This abstraction allows for easy testing and platform-specific
/// implementations (HealthKit for iOS, Google Fit on Android).
abstract class IHealthDataService {
  /// Requests permissions to access health data.
  ///
  /// Returns `true` if permissions were granted, `false` otherwise.
  Future<bool> requestPermissions();

  /// Checks if health data permissions have been granted.
  ///
  /// Returns `true` if permissions are granted, `false` otherwise.
  Future<bool> hasPermissions();

  /// Gets today's step count from the device.
  ///
  /// Returns the step count for today, or `null` if:
  /// - Permissions are not granted
  /// - Health data is not available
  /// - An error occurred
  Future<int?> getTodaySteps();

  /// Gets today's sleep duration in hours from the device.
  ///
  /// Returns the sleep hours for today, or `null` if:
  /// - Permissions are not granted
  /// - Sleep data is not available
  /// - An error occurred
  Future<double?> getTodaySleepHours();

  /// Gets today's water intake in liters from the device.
  ///
  /// Returns the water intake in liters for today, or `null` if:
  /// - Permissions are not granted
  /// - Water data is not available
  /// - Platform doesn't support water tracking
  Future<double?> getTodayWaterLiters();
}

/// Implementation of [IHealthDataService] using the `health` package.
///
/// This service provides cross-platform health data access:
/// - iOS: Uses HealthKit
/// - Android: Uses Google Fit / Health Connect
class HealthDataService implements IHealthDataService {
  Health? _health;
  bool _initialized = false;

  // Health data types we want to access
  static final List<HealthDataType> _healthDataTypes = [
    HealthDataType.STEPS,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_REM,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.WATER,
  ];

  /// Initialize the health service
  Future<void> _initialize() async {
    if (_initialized) return;

    try {
      _health = Health();

      // Check if health data is available on this platform
      try {
        final available = await _health!.hasPermissions(_healthDataTypes);
        if (available == null) {
          Logger.warning(
            'HealthDataService: Health data may not be available on this platform',
            feature: 'health',
            screen: 'health_data_service',
          );
        }
      } catch (e) {
        Logger.warning(
          'HealthDataService: Could not check permissions during initialization',
          feature: 'health',
          screen: 'health_data_service',
        );
      }

      _initialized = true;
    } catch (e, stackTrace) {
      Logger.error(
        'HealthDataService: Error initializing health service',
        error: e,
        stackTrace: stackTrace,
        feature: 'health',
        screen: 'health_data_service',
      );
      _health = null;
      _initialized = true; // Mark as initialized to avoid retrying
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      await _initialize();

      if (_health == null) {
        Logger.warning(
          'HealthDataService: Health service not available',
          feature: 'health',
          screen: 'health_data_service',
        );
        return false;
      }

      // Request permissions
      final granted = await _health!.requestAuthorization(_healthDataTypes);

      Logger.info(
        'HealthDataService: Permission request result: $granted',
        feature: 'health',
        screen: 'health_data_service',
      );

      return granted;
    } catch (e, stackTrace) {
      Logger.error(
        'HealthDataService: Error requesting permissions',
        error: e,
        stackTrace: stackTrace,
        feature: 'health',
        screen: 'health_data_service',
      );
      return false;
    }
  }

  @override
  Future<bool> hasPermissions() async {
    try {
      await _initialize();

      if (_health == null) {
        return false;
      }

      final hasPermissions = await _health!.hasPermissions(_healthDataTypes);
      return hasPermissions == true;
    } catch (e, stackTrace) {
      Logger.error(
        'HealthDataService: Error checking permissions',
        error: e,
        stackTrace: stackTrace,
        feature: 'health',
        screen: 'health_data_service',
      );
      return false;
    }
  }

  @override
  Future<int?> getTodaySteps() async {
    try {
      await _initialize();

      if (_health == null || !(await hasPermissions())) {
        return null;
      }

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Fetch steps data using getHealthDataFromTypes
      final steps = await _health!.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: startOfDay,
        endTime: endOfDay,
      );

      if (steps.isEmpty) {
        Logger.info(
          'HealthDataService: No steps data available for today',
          feature: 'health',
          screen: 'health_data_service',
        );
        return null;
      }

      // Sum all steps for today
      int totalSteps = 0;
      for (final data in steps) {
        if (data.value is NumericHealthValue) {
          totalSteps += (data.value as NumericHealthValue).numericValue.toInt();
        }
      }

      Logger.info(
        'HealthDataService: Retrieved $totalSteps steps for today',
        feature: 'health',
        screen: 'health_data_service',
      );

      return totalSteps;
    } catch (e, stackTrace) {
      Logger.error(
        'HealthDataService: Error getting today steps',
        error: e,
        stackTrace: stackTrace,
        feature: 'health',
        screen: 'health_data_service',
      );
      return null;
    }
  }

  @override
  Future<double?> getTodaySleepHours() async {
    try {
      await _initialize();

      if (_health == null || !(await hasPermissions())) {
        return null;
      }

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Try SLEEP_IN_BED first (most comprehensive - includes time in bed)
      // This is the primary sleep metric for HealthKit/Health Connect
      try {
        final sleepInBedData = await _health!.getHealthDataFromTypes(
          types: [HealthDataType.SLEEP_IN_BED],
          startTime: startOfDay,
          endTime: endOfDay,
        );

        if (sleepInBedData.isNotEmpty) {
          double totalSleepHours = 0.0;
          final sleepSegments = <_DateTimeRange>[];

          // Collect all sleep segments
          for (final data in sleepInBedData) {
            sleepSegments
                .add(_DateTimeRange(start: data.dateFrom, end: data.dateTo));
          }

          // Merge overlapping segments and calculate total duration
          if (sleepSegments.isNotEmpty) {
            // Sort by start time
            sleepSegments.sort((a, b) => a.start.compareTo(b.start));

            // Merge overlapping segments
            final mergedSegments = <_DateTimeRange>[];
            _DateTimeRange? current = sleepSegments[0];

            for (int i = 1; i < sleepSegments.length; i++) {
              final next = sleepSegments[i];
              if (current!.end.isAfter(next.start) ||
                  current.end.isAtSameMomentAs(next.start)) {
                // Segments overlap or are adjacent, merge them
                current = _DateTimeRange(
                  start: current.start.isBefore(next.start)
                      ? current.start
                      : next.start,
                  end: current.end.isAfter(next.end) ? current.end : next.end,
                );
              } else {
                // No overlap, add current and move to next
                mergedSegments.add(current);
                current = next;
              }
            }
            if (current != null) {
              mergedSegments.add(current);
            }

            // Calculate total hours from merged segments
            for (final segment in mergedSegments) {
              final duration = segment.duration;
              totalSleepHours += duration.inSeconds / 3600.0;
            }

            if (totalSleepHours > 0) {
              Logger.info(
                'HealthDataService: Retrieved ${totalSleepHours.toStringAsFixed(2)} hours of sleep (SLEEP_IN_BED) for today',
                feature: 'health',
                screen: 'health_data_service',
              );
              return totalSleepHours;
            }
          }
        }
      } catch (e) {
        Logger.warning(
          'HealthDataService: Could not fetch SLEEP_IN_BED, trying SLEEP_ASLEEP: $e',
          feature: 'health',
          screen: 'health_data_service',
        );
      }

      // Fallback to SLEEP_ASLEEP if SLEEP_IN_BED is not available
      try {
        final sleepAsleepData = await _health!.getHealthDataFromTypes(
          types: [HealthDataType.SLEEP_ASLEEP],
          startTime: startOfDay,
          endTime: endOfDay,
        );

        if (sleepAsleepData.isNotEmpty) {
          double totalSleepHours = 0.0;
          final sleepSegments = <_DateTimeRange>[];

          for (final data in sleepAsleepData) {
            sleepSegments
                .add(_DateTimeRange(start: data.dateFrom, end: data.dateTo));
          }

          if (sleepSegments.isNotEmpty) {
            // Merge overlapping segments
            sleepSegments.sort((a, b) => a.start.compareTo(b.start));
            final mergedSegments = <_DateTimeRange>[];
            _DateTimeRange? current = sleepSegments[0];

            for (int i = 1; i < sleepSegments.length; i++) {
              final next = sleepSegments[i];
              if (current!.end.isAfter(next.start) ||
                  current.end.isAtSameMomentAs(next.start)) {
                current = _DateTimeRange(
                  start: current.start.isBefore(next.start)
                      ? current.start
                      : next.start,
                  end: current.end.isAfter(next.end) ? current.end : next.end,
                );
              } else {
                mergedSegments.add(current);
                current = next;
              }
            }
            if (current != null) {
              mergedSegments.add(current);
            }

            for (final segment in mergedSegments) {
              final duration = segment.duration;
              totalSleepHours += duration.inSeconds / 3600.0;
            }

            if (totalSleepHours > 0) {
              Logger.info(
                'HealthDataService: Retrieved ${totalSleepHours.toStringAsFixed(2)} hours of sleep (SLEEP_ASLEEP) for today',
                feature: 'health',
                screen: 'health_data_service',
              );
              return totalSleepHours;
            }
          }
        }
      } catch (e) {
        Logger.warning(
          'HealthDataService: Could not fetch SLEEP_ASLEEP: $e',
          feature: 'health',
          screen: 'health_data_service',
        );
      }

      Logger.info(
        'HealthDataService: No sleep data available for today',
        feature: 'health',
        screen: 'health_data_service',
      );
      return null;
    } catch (e, stackTrace) {
      Logger.error(
        'HealthDataService: Error getting today sleep',
        error: e,
        stackTrace: stackTrace,
        feature: 'health',
        screen: 'health_data_service',
      );
      return null;
    }
  }

  @override
  Future<double?> getTodayWaterLiters() async {
    try {
      await _initialize();

      if (_health == null || !(await hasPermissions())) {
        return null;
      }

      // Water tracking may not be available on all platforms
      if (Platform.isAndroid) {
        // Google Fit / Health Connect may not support water tracking directly
        Logger.info(
          'HealthDataService: Water tracking may not be available on Android',
          feature: 'health',
          screen: 'health_data_service',
        );
        return null;
      }

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Fetch water data
      final waterData = await _health!.getHealthDataFromTypes(
        types: [HealthDataType.WATER],
        startTime: startOfDay,
        endTime: endOfDay,
      );

      if (waterData.isEmpty) {
        Logger.info(
          'HealthDataService: No water data available for today',
          feature: 'health',
          screen: 'health_data_service',
        );
        return null;
      }

      // Sum all water intake for today (assume in liters for HealthKit)
      double totalWaterLiters = 0.0;
      for (final data in waterData) {
        if (data.value is NumericHealthValue) {
          final value = (data.value as NumericHealthValue).numericValue;
          // HealthKit uses liters
          totalWaterLiters += value;
        }
      }

      Logger.info(
        'HealthDataService: Retrieved ${totalWaterLiters.toStringAsFixed(2)} liters of water for today',
        feature: 'health',
        screen: 'health_data_service',
      );

      return totalWaterLiters;
    } catch (e, stackTrace) {
      Logger.error(
        'HealthDataService: Error getting today water',
        error: e,
        stackTrace: stackTrace,
        feature: 'health',
        screen: 'health_data_service',
      );
      return null;
    }
  }
}
