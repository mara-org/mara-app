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

  /// Gets all historical sleep data from the device.
  ///
  /// Returns a map of date (YYYY-MM-DD) to sleep hours for all available dates.
  /// Returns empty map if no data is available.
  Future<Map<String, double>> getAllSleepData();

  /// Gets all historical steps data from the device.
  ///
  /// Returns a map of date (YYYY-MM-DD) to step count for all available dates.
  /// Returns empty map if no data is available.
  Future<Map<String, int>> getAllStepsData();

  /// Gets all historical water intake data from the device.
  ///
  /// Returns a map of date (YYYY-MM-DD) to water liters for all available dates.
  /// Returns empty map if no data is available.
  Future<Map<String, double>> getAllWaterData();
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

      // Request permissions for sleep and steps data types
      // This ensures we're requesting the right permissions
      final healthDataTypesToRequest = [
        HealthDataType.SLEEP_IN_BED,
        HealthDataType.SLEEP_ASLEEP,
        HealthDataType.STEPS,
      ];
      
      final granted = await _health!.requestAuthorization(healthDataTypesToRequest);

      Logger.info(
        'HealthDataService: Permission request result: $granted',
        feature: 'health',
        screen: 'health_data_service',
        extra: {'requestedTypes': healthDataTypesToRequest.map((e) => e.toString()).toList()},
      );

      // After requesting, verify permissions are actually granted
      if (granted) {
        // Wait a moment for permissions to propagate (especially on iOS)
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Use our hasPermissions method which does a test read
        final verified = await hasPermissions();
        Logger.info(
          'HealthDataService: Permission verification after request: $verified',
          feature: 'health',
          screen: 'health_data_service',
        );
        return verified;
      }

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
        Logger.warning(
          'HealthDataService: Health service is null, cannot check permissions',
          feature: 'health',
          screen: 'health_data_service',
        );
        return false;
      }

      // Check permissions for sleep and steps data types
      // Users might grant some permissions but not all health data types
      final healthDataTypesToCheck = [
        HealthDataType.SLEEP_IN_BED,
        HealthDataType.SLEEP_ASLEEP,
        HealthDataType.STEPS,
      ];
      
      final permissionResult = await _health!.hasPermissions(healthDataTypesToCheck);
      final hasPermissions = permissionResult == true;
      
      Logger.info(
        'HealthDataService: Permission check result: $hasPermissions (raw: $permissionResult)',
        feature: 'health',
        screen: 'health_data_service',
      );
      
      // If the permission check is unclear (null), try to actually read data
      // This is more reliable than just checking permissions
      if (permissionResult != true && permissionResult != false) {
        Logger.info(
          'HealthDataService: Permission check returned null/uncertain, attempting test read',
          feature: 'health',
          screen: 'health_data_service',
        );
        
        // Try a test read to see if we can actually access health data
        try {
          final now = DateTime.now();
          final testStart = now.subtract(const Duration(days: 7));
          final testEnd = now;
          
          // Try to read data - if this succeeds, we have permissions
          await _health!.getHealthDataFromTypes(
            types: healthDataTypesToCheck,
            startTime: testStart,
            endTime: testEnd,
          );
          
          // If we can read data (even if empty), we have permissions
          Logger.info(
            'HealthDataService: Test read successful, permissions appear to be granted',
            feature: 'health',
            screen: 'health_data_service',
          );
          return true;
        } catch (e) {
          Logger.warning(
            'HealthDataService: Test read failed, likely no permissions: $e',
            feature: 'health',
            screen: 'health_data_service',
          );
          return false;
        }
      }
      
      return hasPermissions;
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
      // Note: HealthKit/Google Fit may return multiple entries per day
      // We sum them to get the total daily steps
      int totalSteps = 0;
      final stepValues = <int>[];
      
      for (final data in steps) {
        if (data.value is NumericHealthValue) {
          final stepValue = (data.value as NumericHealthValue).numericValue.toInt();
          stepValues.add(stepValue);
          totalSteps += stepValue;
        }
      }

      Logger.info(
        'HealthDataService: Retrieved $totalSteps steps for today from ${stepValues.length} entries (values: $stepValues)',
        feature: 'health',
        screen: 'health_data_service',
      );

      return totalSteps > 0 ? totalSteps : null;
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

      if (_health == null) {
        Logger.warning(
          'HealthDataService: Health service is null, cannot get sleep data',
          feature: 'health',
          screen: 'health_data_service',
        );
        return null;
      }

      final permissionsGranted = await hasPermissions();
      if (!permissionsGranted) {
        Logger.warning(
          'HealthDataService: Permissions not granted, cannot get sleep data',
          feature: 'health',
          screen: 'health_data_service',
        );
        return null;
      }

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      // Query from 2 days ago to capture sleep sessions that might span multiple days
      // This ensures we capture overnight sleep that started 2 nights ago
      final queryStart = startOfDay.subtract(const Duration(days: 2));
      
      Logger.info(
        'HealthDataService: Querying sleep data from ${queryStart.toIso8601String()} to ${endOfDay.toIso8601String()} (today: ${startOfDay.toIso8601String()})',
        feature: 'health',
        screen: 'health_data_service',
      );

      // Try SLEEP_IN_BED first (most comprehensive - includes time in bed)
      // This is the primary sleep metric for HealthKit/Health Connect
      try {
        Logger.info(
          'HealthDataService: Attempting to fetch SLEEP_IN_BED data',
          feature: 'health',
          screen: 'health_data_service',
        );
        
        // Query from 2 days ago to today to capture sleep sessions that span midnight
        final sleepInBedData = await _health!.getHealthDataFromTypes(
          types: [HealthDataType.SLEEP_IN_BED],
          startTime: queryStart,
          endTime: endOfDay,
        );

        Logger.info(
          'HealthDataService: SLEEP_IN_BED query returned ${sleepInBedData.length} entries',
          feature: 'health',
          screen: 'health_data_service',
        );

        if (sleepInBedData.isNotEmpty) {
          double totalSleepHours = 0.0;
          final sleepSegments = <_DateTimeRange>[];

          // Log all raw sleep data entries for debugging
          final entriesInfo = sleepInBedData.map((e) => {
            'from': e.dateFrom.toIso8601String(),
            'to': e.dateTo.toIso8601String(),
            'value': e.value.toString(),
          }).toList();
          
          Logger.info(
            'HealthDataService: Processing ${sleepInBedData.length} sleep entries',
            feature: 'health',
            screen: 'health_data_service',
            extra: {'entries': entriesInfo},
          );

          // Collect all sleep segments that overlap with today
          // A segment overlaps with today if:
          // - It starts before today and ends during/after today (overnight sleep)
          // - It starts during today (daytime nap)
          // - It starts before today and ends after today (very long sleep)
          for (final data in sleepInBedData) {
            final segmentStart = data.dateFrom;
            final segmentEnd = data.dateTo;
            
            // Check if this segment overlaps with today at all
            // Overlap exists if: segment starts before today ends AND segment ends after today starts
            final overlapsWithToday = segmentStart.isBefore(endOfDay) && segmentEnd.isAfter(startOfDay);
            
            if (overlapsWithToday) {
              // Calculate the portion that overlaps with today
              final overlapStart = segmentStart.isBefore(startOfDay) ? startOfDay : segmentStart;
              final overlapEnd = segmentEnd.isAfter(endOfDay) ? endOfDay : segmentEnd;
              
              if (overlapEnd.isAfter(overlapStart)) {
                final duration = overlapEnd.difference(overlapStart);
                Logger.info(
                  'HealthDataService: Including sleep segment: ${overlapStart.toIso8601String()} to ${overlapEnd.toIso8601String()} (${duration.inHours}h ${duration.inMinutes.remainder(60)}m)',
                  feature: 'health',
                  screen: 'health_data_service',
                );
                sleepSegments.add(_DateTimeRange(start: overlapStart, end: overlapEnd));
              }
            } else {
              Logger.info(
                'HealthDataService: Excluding sleep segment (no overlap with today): ${segmentStart.toIso8601String()} to ${segmentEnd.toIso8601String()}',
                feature: 'health',
                screen: 'health_data_service',
              );
            }
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
        Logger.info(
          'HealthDataService: Attempting to fetch SLEEP_ASLEEP data as fallback',
          feature: 'health',
          screen: 'health_data_service',
        );
        
        // Query from 2 days ago to today to capture sleep sessions that span midnight
        final sleepAsleepData = await _health!.getHealthDataFromTypes(
          types: [HealthDataType.SLEEP_ASLEEP],
          startTime: queryStart,
          endTime: endOfDay,
        );

        Logger.info(
          'HealthDataService: SLEEP_ASLEEP query returned ${sleepAsleepData.length} entries',
          feature: 'health',
          screen: 'health_data_service',
        );

        if (sleepAsleepData.isNotEmpty) {
          double totalSleepHours = 0.0;
          final sleepSegments = <_DateTimeRange>[];

          // Log all raw sleep data entries for debugging
          final asleepEntriesInfo = sleepAsleepData.map((e) => {
            'from': e.dateFrom.toIso8601String(),
            'to': e.dateTo.toIso8601String(),
            'value': e.value.toString(),
          }).toList();
          
          Logger.info(
            'HealthDataService: Processing ${sleepAsleepData.length} SLEEP_ASLEEP entries',
            feature: 'health',
            screen: 'health_data_service',
            extra: {'entries': asleepEntriesInfo},
          );

          // Collect all sleep segments that overlap with today
          for (final data in sleepAsleepData) {
            final segmentStart = data.dateFrom;
            final segmentEnd = data.dateTo;
            
            // Check if this segment overlaps with today at all
            final overlapsWithToday = segmentStart.isBefore(endOfDay) && segmentEnd.isAfter(startOfDay);
            
            if (overlapsWithToday) {
              // Calculate the portion that overlaps with today
              final overlapStart = segmentStart.isBefore(startOfDay) ? startOfDay : segmentStart;
              final overlapEnd = segmentEnd.isAfter(endOfDay) ? endOfDay : segmentEnd;
              
              if (overlapEnd.isAfter(overlapStart)) {
                final duration = overlapEnd.difference(overlapStart);
                Logger.info(
                  'HealthDataService: Including SLEEP_ASLEEP segment: ${overlapStart.toIso8601String()} to ${overlapEnd.toIso8601String()} (${duration.inHours}h ${duration.inMinutes.remainder(60)}m)',
                  feature: 'health',
                  screen: 'health_data_service',
                );
                sleepSegments.add(_DateTimeRange(start: overlapStart, end: overlapEnd));
              }
            } else {
              Logger.info(
                'HealthDataService: Excluding SLEEP_ASLEEP segment (no overlap with today): ${segmentStart.toIso8601String()} to ${segmentEnd.toIso8601String()}',
                feature: 'health',
                screen: 'health_data_service',
              );
            }
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

      // If we got here, no sleep data was found. Try a diagnostic query
      // to see if there's ANY sleep data available (last 7 days)
      try {
        Logger.info(
          'HealthDataService: No sleep data found for today, running diagnostic query (last 7 days)',
          feature: 'health',
          screen: 'health_data_service',
        );
        
        final diagnosticStart = DateTime.now().subtract(const Duration(days: 7));
        final diagnosticEnd = DateTime.now();
        
        // Try all sleep types to see what's available
        final allSleepTypes = [
          HealthDataType.SLEEP_IN_BED,
          HealthDataType.SLEEP_ASLEEP,
          HealthDataType.SLEEP_DEEP,
          HealthDataType.SLEEP_REM,
          HealthDataType.SLEEP_AWAKE,
        ];
        
        for (final sleepType in allSleepTypes) {
          try {
            final diagnosticData = await _health!.getHealthDataFromTypes(
              types: [sleepType],
              startTime: diagnosticStart,
              endTime: diagnosticEnd,
            );
            
            if (diagnosticData.isNotEmpty) {
              Logger.info(
                'HealthDataService: Found ${diagnosticData.length} entries of type $sleepType in last 7 days',
                feature: 'health',
                screen: 'health_data_service',
                extra: {
                  'firstEntry': diagnosticData.first.dateFrom.toIso8601String(),
                  'lastEntry': diagnosticData.last.dateTo.toIso8601String(),
                },
              );
            } else {
              Logger.info(
                'HealthDataService: No entries found for type $sleepType in last 7 days',
                feature: 'health',
                screen: 'health_data_service',
              );
            }
          } catch (e) {
            Logger.warning(
              'HealthDataService: Error querying $sleepType: $e',
              feature: 'health',
              screen: 'health_data_service',
            );
          }
        }
      } catch (e) {
        Logger.warning(
          'HealthDataService: Error running diagnostic query: $e',
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

  @override
  Future<Map<String, double>> getAllSleepData() async {
    final result = <String, double>{};
    
    try {
      await _initialize();

      if (_health == null || !(await hasPermissions())) {
        Logger.warning(
          'HealthDataService: Cannot fetch all sleep data - no permissions or service unavailable',
          feature: 'health',
          screen: 'health_data_service',
        );
        return result;
      }

      // Query from a very early date to now to get all available data
      // HealthKit/Health Connect typically stores data for years
      final now = DateTime.now();
      final startDate = DateTime(2010, 1, 1); // Start from 2010 to capture all historical data
      final endDate = now.add(const Duration(days: 1)); // Include today

      Logger.info(
        'HealthDataService: Fetching all sleep data from ${startDate.toIso8601String()} to ${endDate.toIso8601String()}',
        feature: 'health',
        screen: 'health_data_service',
      );

      // Try SLEEP_IN_BED first
      try {
        final sleepInBedData = await _health!.getHealthDataFromTypes(
          types: [HealthDataType.SLEEP_IN_BED],
          startTime: startDate,
          endTime: endDate,
        );

        Logger.info(
          'HealthDataService: Retrieved ${sleepInBedData.length} SLEEP_IN_BED entries',
          feature: 'health',
          screen: 'health_data_service',
        );

        // Group by date and sum hours per day
        // For sleep sessions that span midnight, count the sleep for the day it ends (wake-up day)
        for (final data in sleepInBedData) {
          final startDate = DateTime(data.dateFrom.year, data.dateFrom.month, data.dateFrom.day);
          final endDate = DateTime(data.dateTo.year, data.dateTo.month, data.dateTo.day);
          
          final duration = data.dateTo.difference(data.dateFrom);
          final totalHours = duration.inSeconds / 3600.0;
          
          if (startDate == endDate) {
            // Sleep session is within a single day
            final dateKey = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
            result[dateKey] = (result[dateKey] ?? 0.0) + totalHours;
          } else {
            // Sleep session spans midnight - split between days
            // Count most of the sleep for the wake-up day (end date)
            final endDateKey = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
            final startDateKey = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
            
            // Calculate hours for each day
            final hoursBeforeMidnight = DateTime(startDate.year, startDate.month, startDate.day, 23, 59, 59)
                .difference(data.dateFrom)
                .inSeconds / 3600.0;
            final hoursAfterMidnight = totalHours - hoursBeforeMidnight;
            
            // Add to both days
            result[startDateKey] = (result[startDateKey] ?? 0.0) + hoursBeforeMidnight;
            result[endDateKey] = (result[endDateKey] ?? 0.0) + hoursAfterMidnight;
          }
        }
      } catch (e) {
        Logger.warning(
          'HealthDataService: Could not fetch SLEEP_IN_BED, trying SLEEP_ASLEEP: $e',
          feature: 'health',
          screen: 'health_data_service',
        );
      }

      // Fallback to SLEEP_ASLEEP if needed or to supplement
      if (result.isEmpty) {
        try {
          final sleepAsleepData = await _health!.getHealthDataFromTypes(
            types: [HealthDataType.SLEEP_ASLEEP],
            startTime: startDate,
            endTime: endDate,
          );

          Logger.info(
            'HealthDataService: Retrieved ${sleepAsleepData.length} SLEEP_ASLEEP entries',
            feature: 'health',
            screen: 'health_data_service',
          );

          // Group by date and sum hours per day
          // For sleep sessions that span midnight, count the sleep for the day it ends (wake-up day)
          for (final data in sleepAsleepData) {
            final startDate = DateTime(data.dateFrom.year, data.dateFrom.month, data.dateFrom.day);
            final endDate = DateTime(data.dateTo.year, data.dateTo.month, data.dateTo.day);
            
            final duration = data.dateTo.difference(data.dateFrom);
            final totalHours = duration.inSeconds / 3600.0;
            
            if (startDate == endDate) {
              // Sleep session is within a single day
              final dateKey = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
              result[dateKey] = (result[dateKey] ?? 0.0) + totalHours;
            } else {
              // Sleep session spans midnight - split between days
              final endDateKey = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
              final startDateKey = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
              
              // Calculate hours for each day
              final hoursBeforeMidnight = DateTime(startDate.year, startDate.month, startDate.day, 23, 59, 59)
                  .difference(data.dateFrom)
                  .inSeconds / 3600.0;
              final hoursAfterMidnight = totalHours - hoursBeforeMidnight;
              
              // Add to both days
              result[startDateKey] = (result[startDateKey] ?? 0.0) + hoursBeforeMidnight;
              result[endDateKey] = (result[endDateKey] ?? 0.0) + hoursAfterMidnight;
            }
          }
        } catch (e) {
          Logger.warning(
            'HealthDataService: Could not fetch SLEEP_ASLEEP: $e',
            feature: 'health',
            screen: 'health_data_service',
          );
        }
      }

      Logger.info(
        'HealthDataService: Retrieved sleep data for ${result.length} days',
        feature: 'health',
        screen: 'health_data_service',
      );

      return result;
    } catch (e, stackTrace) {
      Logger.error(
        'HealthDataService: Error getting all sleep data',
        error: e,
        stackTrace: stackTrace,
        feature: 'health',
        screen: 'health_data_service',
      );
      return result;
    }
  }

  @override
  Future<Map<String, int>> getAllStepsData() async {
    final result = <String, int>{};
    
    try {
      await _initialize();

      if (_health == null || !(await hasPermissions())) {
        Logger.warning(
          'HealthDataService: Cannot fetch all steps data - no permissions or service unavailable',
          feature: 'health',
          screen: 'health_data_service',
        );
        return result;
      }

      // Query from a very early date to now to get all available data
      final now = DateTime.now();
      final startDate = DateTime(2010, 1, 1); // Start from 2010 to capture all historical data
      final endDate = now.add(const Duration(days: 1)); // Include today

      Logger.info(
        'HealthDataService: Fetching all steps data from ${startDate.toIso8601String()} to ${endDate.toIso8601String()}',
        feature: 'health',
        screen: 'health_data_service',
      );

      final stepsData = await _health!.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: startDate,
        endTime: endDate,
      );

      Logger.info(
        'HealthDataService: Retrieved ${stepsData.length} steps entries',
        feature: 'health',
        screen: 'health_data_service',
      );

      // Group by date and sum steps per day
      for (final data in stepsData) {
        if (data.value is NumericHealthValue) {
          final date = DateTime(data.dateFrom.year, data.dateFrom.month, data.dateFrom.day);
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          
          final steps = (data.value as NumericHealthValue).numericValue.toInt();
          result[dateKey] = (result[dateKey] ?? 0) + steps;
        }
      }

      Logger.info(
        'HealthDataService: Retrieved steps data for ${result.length} days',
        feature: 'health',
        screen: 'health_data_service',
      );

      return result;
    } catch (e, stackTrace) {
      Logger.error(
        'HealthDataService: Error getting all steps data',
        error: e,
        stackTrace: stackTrace,
        feature: 'health',
        screen: 'health_data_service',
      );
      return result;
    }
  }

  @override
  Future<Map<String, double>> getAllWaterData() async {
    final result = <String, double>{};
    
    try {
      await _initialize();

      if (_health == null || !(await hasPermissions())) {
        Logger.warning(
          'HealthDataService: Cannot fetch all water data - no permissions or service unavailable',
          feature: 'health',
          screen: 'health_data_service',
        );
        return result;
      }

      // Water tracking may not be available on all platforms
      if (Platform.isAndroid) {
        // Google Fit / Health Connect may not support water tracking directly
        Logger.info(
          'HealthDataService: Water tracking may not be available on Android',
          feature: 'health',
          screen: 'health_data_service',
        );
        return result;
      }

      // Query from a very early date to now to get all available data
      final now = DateTime.now();
      final startDate = DateTime(2010, 1, 1); // Start from 2010 to capture all historical data
      final endDate = now.add(const Duration(days: 1)); // Include today

      Logger.info(
        'HealthDataService: Fetching all water data from ${startDate.toIso8601String()} to ${endDate.toIso8601String()}',
        feature: 'health',
        screen: 'health_data_service',
      );

      final waterData = await _health!.getHealthDataFromTypes(
        types: [HealthDataType.WATER],
        startTime: startDate,
        endTime: endDate,
      );

      Logger.info(
        'HealthDataService: Retrieved ${waterData.length} water entries',
        feature: 'health',
        screen: 'health_data_service',
      );

      // Group by date and sum water per day
      for (final data in waterData) {
        if (data.value is NumericHealthValue) {
          final date = DateTime(data.dateFrom.year, data.dateFrom.month, data.dateFrom.day);
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          
          final waterLiters = (data.value as NumericHealthValue).numericValue;
          result[dateKey] = (result[dateKey] ?? 0.0) + waterLiters;
        }
      }

      Logger.info(
        'HealthDataService: Retrieved water data for ${result.length} days',
        feature: 'health',
        screen: 'health_data_service',
      );

      return result;
    } catch (e, stackTrace) {
      Logger.error(
        'HealthDataService: Error getting all water data',
        error: e,
        stackTrace: stackTrace,
        feature: 'health',
        screen: 'health_data_service',
      );
      return result;
    }
  }
}
