import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Retry interceptor for Dio HTTP client
///
/// Implements exponential backoff retry logic for network requests.
/// Retries on:
/// - Network errors (connection timeouts, no internet)
/// - 5xx server errors (temporary server issues)
///
/// Configuration:
/// - maxRetries: Maximum number of retry attempts (default: 3)
/// - retryDelays: List of delays between retries in milliseconds (default: [200, 400, 800])
///
/// Usage:
/// ```dart
/// final dio = Dio();
/// dio.interceptors.add(RetryInterceptor());
/// ```
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final List<int> retryDelays;

  RetryInterceptor({
    this.maxRetries = 3,
    List<int>? retryDelays,
  }) : retryDelays = retryDelays ?? [200, 400, 800];

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check if we should retry
    if (!_shouldRetry(err)) {
      return handler.reject(err);
    }

    // Get retry count from options
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    if (retryCount >= maxRetries) {
      if (kDebugMode) {
        debugPrint('Max retries ($maxRetries) reached for ${err.requestOptions.path}');
      }
      return handler.reject(err);
    }

    // Calculate delay (exponential backoff)
    final delay = retryCount < retryDelays.length
        ? retryDelays[retryCount]
        : retryDelays.last;

    if (kDebugMode) {
      debugPrint(
        'Retrying ${err.requestOptions.path} (attempt ${retryCount + 1}/$maxRetries) after ${delay}ms',
      );
    }

    // Wait before retrying
    await Future.delayed(Duration(milliseconds: delay));

    // Update retry count
    err.requestOptions.extra['retryCount'] = retryCount + 1;

    try {
      // Retry the request
      final response = await Dio().fetch(
        err.requestOptions.copyWith(
          extra: err.requestOptions.extra,
        ),
      );
      return handler.resolve(response);
    } catch (e) {
      // If retry also fails, continue with error handling
      if (e is DioException) {
        return onError(e, handler);
      }
      return handler.reject(err);
    }
  }

  /// Determine if an error should be retried
  bool _shouldRetry(DioException err) {
    // Retry on network errors
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }

    // Retry on 5xx server errors (temporary server issues)
    if (err.response != null) {
      final statusCode = err.response!.statusCode;
      if (statusCode != null && statusCode >= 500 && statusCode < 600) {
        return true;
      }
    }

    // Don't retry on client errors (4xx) or other errors
    return false;
  }
}

