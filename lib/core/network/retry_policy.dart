import 'package:dio/dio.dart';
import 'api_exceptions.dart';

/// Retry policy for API requests.
///
/// Only retries on network errors (timeouts, connection failures).
/// Does NOT retry on 4xx/5xx errors to avoid duplicate operations.
class RetryPolicy {
  /// Maximum number of retries.
  final int maxRetries;

  /// Base delay between retries (exponential backoff).
  final Duration baseDelay;

  RetryPolicy({
    this.maxRetries = 2,
    this.baseDelay = const Duration(milliseconds: 500),
  });

  /// Check if an error should be retried.
  ///
  /// Only retries on network errors (timeouts, connection failures).
  /// Does NOT retry on:
  /// - 4xx errors (client errors - bad request, auth, quota)
  /// - 5xx errors (server errors - might be duplicate operations)
  bool shouldRetry(DioException error, int attemptCount) {
    if (attemptCount >= maxRetries) {
      return false;
    }

    // Only retry on network errors (timeouts, connection failures)
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return true;
    }

    // Do NOT retry on HTTP errors (4xx, 5xx)
    // These indicate application-level issues, not network problems
    return false;
  }

  /// Calculate delay before retry (exponential backoff).
  Duration getRetryDelay(int attemptCount) {
    final multiplier = 1 << attemptCount; // 1, 2, 4, 8...
    return Duration(
      milliseconds: baseDelay.inMilliseconds * multiplier,
    );
  }
}

