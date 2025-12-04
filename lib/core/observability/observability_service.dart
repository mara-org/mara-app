/// Unified observability service for Mara app.
///
/// This service wraps logger, analytics, and crash reporter to provide
/// a single interface for tracking events, errors, and performance metrics.
///
/// Usage:
/// ```dart
/// final observability = ObservabilityService();
/// observability.trackEvent('user_signed_in', {'method': 'email'});
/// observability.trackError('Failed to load data', error, stackTrace);
/// observability.trackPerformanceMetric('screen_load_time', 150, 'ms');
/// ```
import '../analytics/analytics_service.dart';
import '../utils/crash_reporter.dart';
import '../utils/logger.dart';

class ObservabilityService {
  final AnalyticsService _analytics;
  final CrashReporter _crashReporter;

  ObservabilityService({
    AnalyticsService? analytics,
    CrashReporter? crashReporter,
  })  : _analytics = analytics ?? AnalyticsService(),
        _crashReporter = crashReporter ?? CrashReporter();

  /// Tracks a custom event.
  ///
  /// [eventName] - Name of the event (e.g., 'user_signed_in', 'message_sent')
  /// [parameters] - Optional event parameters
  /// [screen] - Optional screen name for context
  /// [feature] - Optional feature name for context
  void trackEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
    String? screen,
    String? feature,
  }) {
    // Log to structured logger
    Logger.info(
      'Event: $eventName',
      screen: screen,
      feature: feature ?? 'observability',
      extra: parameters,
    );

    // Track in analytics
    _analytics.logEvent(
      eventName: eventName,
      parameters: parameters ?? {},
    );
  }

  /// Tracks an error.
  ///
  /// [message] - Error message
  /// [error] - The error object
  /// [stackTrace] - Stack trace (optional)
  /// [screen] - Optional screen name for context
  /// [feature] - Optional feature name for context
  /// [fatal] - Whether this is a fatal error (default: false)
  void trackError(
    String message,
    Object error, {
    StackTrace? stackTrace,
    String? screen,
    String? feature,
    bool fatal = false,
  }) {
    // Log to structured logger
    if (fatal) {
      Logger.critical(
        message,
        screen: screen,
        feature: feature ?? 'observability',
        error: error,
        stackTrace: stackTrace,
      );
    } else {
      Logger.error(
        message,
        screen: screen,
        feature: feature ?? 'observability',
        error: error,
        stackTrace: stackTrace,
      );
    }

    // Report to crash reporter
    _crashReporter.recordError(
      error,
      stackTrace,
      reason: message,
      fatal: fatal,
    );
  }

  /// Tracks a performance metric.
  ///
  /// [metricName] - Name of the metric (e.g., 'screen_load_time', 'api_response_time')
  /// [value] - Metric value
  /// [unit] - Unit of measurement (e.g., 'ms', 'bytes', 'count')
  /// [screen] - Optional screen name for context
  /// [feature] - Optional feature name for context
  void trackPerformanceMetric(
    String metricName,
    num value, {
    String unit = 'ms',
    String? screen,
    String? feature,
  }) {
    // Log to structured logger
    Logger.info(
      'Performance: $metricName = $value $unit',
      screen: screen,
      feature: feature ?? 'observability',
      extra: {
        'metric_name': metricName,
        'value': value,
        'unit': unit,
      },
    );

    // Track in analytics as a custom event
    _analytics.logEvent(
      eventName: 'performance_metric',
      parameters: {
        'metric_name': metricName,
        'value': value,
        'unit': unit,
        if (screen != null) 'screen': screen,
        if (feature != null) 'feature': feature,
      },
    );
  }

  /// Tracks a screen view.
  ///
  /// [screenName] - Name of the screen
  /// [parameters] - Optional screen view parameters
  void trackScreenView(
    String screenName, {
    Map<String, dynamic>? parameters,
  }) {
    // Log to structured logger
    Logger.info(
      'Screen view: $screenName',
      screen: screenName,
      feature: 'navigation',
      extra: parameters,
    );

    // Track in analytics
    _analytics.logScreenView(
      screenName: screenName,
      parameters: parameters ?? {},
    );

    // Update logger's current screen context
    Logger.setScreen(screenName);
  }

  /// Tracks a user action.
  ///
  /// [action] - Name of the action (e.g., 'button_tapped', 'form_submitted')
  /// [screen] - Screen where action occurred
  /// [feature] - Feature where action occurred
  /// [parameters] - Optional action parameters
  void trackUserAction(
    String action, {
    required String screen,
    required String feature,
    Map<String, dynamic>? parameters,
  }) {
    trackEvent(
      'user_action_$action',
      parameters: {
        'action': action,
        'screen': screen,
        'feature': feature,
        ...?parameters,
      },
      screen: screen,
      feature: feature,
    );
  }

  /// Tracks a flow start.
  ///
  /// [flowName] - Name of the flow (e.g., 'sign_in', 'start_chat')
  /// [parameters] - Optional flow parameters
  void trackFlowStart(
    String flowName, {
    Map<String, dynamic>? parameters,
  }) {
    trackEvent(
      'flow_start',
      parameters: {
        'flow_name': flowName,
        ...?parameters,
      },
      feature: flowName,
    );
  }

  /// Tracks a flow completion (success).
  ///
  /// [flowName] - Name of the flow
  /// [duration] - Flow duration in milliseconds
  /// [parameters] - Optional flow parameters
  void trackFlowSuccess(
    String flowName,
    int duration, {
    Map<String, dynamic>? parameters,
  }) {
    trackEvent(
      'flow_success',
      parameters: {
        'flow_name': flowName,
        'duration_ms': duration,
        ...?parameters,
      },
      feature: flowName,
    );

    // Also track as performance metric
    trackPerformanceMetric(
      'flow_duration',
      duration,
      unit: 'ms',
      feature: flowName,
    );
  }

  /// Tracks a flow failure.
  ///
  /// [flowName] - Name of the flow
  /// [error] - Error that caused failure
  /// [stackTrace] - Stack trace (optional)
  /// [parameters] - Optional flow parameters
  void trackFlowFailure(
    String flowName,
    Object error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? parameters,
  }) {
    trackError(
      'Flow failed: $flowName',
      error,
      stackTrace: stackTrace,
      feature: flowName,
      extra: parameters,
    );

    trackEvent(
      'flow_failure',
      parameters: {
        'flow_name': flowName,
        'error': error.toString(),
        ...?parameters,
      },
      feature: flowName,
    );
  }
}
