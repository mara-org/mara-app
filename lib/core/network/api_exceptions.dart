import 'package:dio/dio.dart';

/// Base exception for API errors.
abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// 401 Unauthorized - Authentication required.
class UnauthorizedException extends ApiException {
  UnauthorizedException([String? message])
      : super(message ?? 'Authentication required', 401);
}

/// 403 Forbidden - Quota/plan restriction.
class ForbiddenException extends ApiException {
  final String? reason;

  ForbiddenException([String? message, this.reason])
      : super(message ?? 'Access forbidden', 403);
}

/// 429 Too Many Requests - Rate limit exceeded.
class RateLimitException extends ApiException {
  final Duration? retryAfter;

  RateLimitException([String? message, this.retryAfter])
      : super(message ?? 'Too many requests. Please try again later.', 429);
}

/// 500+ Server Error - Service temporarily unavailable.
class ServerException extends ApiException {
  ServerException([String? message])
      : super(message ?? 'Service temporarily unavailable', 500);
}

/// Network error - Connection failed.
class NetworkException extends ApiException {
  NetworkException([String? message])
      : super(message ?? 'Network error. Please check your connection', null);
}

/// Unknown/other error.
class UnknownApiException extends ApiException {
  UnknownApiException([String? message])
      : super(message ?? 'An unexpected error occurred', null);
}

/// Map DioException to typed API exceptions.
ApiException mapDioException(DioException error) {
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.connectionError) {
    return NetworkException();
  }

  final statusCode = error.response?.statusCode;

  switch (statusCode) {
    case 401:
      return UnauthorizedException(
        error.response?.data?['error']?['message'] as String?,
      );
    case 403:
      return ForbiddenException(
        error.response?.data?['error']?['message'] as String?,
        error.response?.data?['error']?['reason'] as String?,
      );
    case 429:
      final retryAfter = error.response?.headers.value('retry-after');
      Duration? retryDuration;
      if (retryAfter != null) {
        final seconds = int.tryParse(retryAfter);
        if (seconds != null) {
          retryDuration = Duration(seconds: seconds);
        }
      }
      return RateLimitException(
        error.response?.data?['error']?['message'] as String?,
        retryDuration,
      );
    case 500:
    case 502:
    case 503:
    case 504:
      return ServerException(
        error.response?.data?['error']?['message'] as String?,
      );
    default:
      return UnknownApiException(
        error.response?.data?['error']?['message'] as String?,
      );
  }
}

