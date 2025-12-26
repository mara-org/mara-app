/// Exception thrown when email rate limit is exceeded.
///
/// This is separate from the API RateLimitException in api_exceptions.dart
/// because it's used for client-side email rate limiting (verification, password reset).
class RateLimitException implements Exception {
  final String message;
  final int? minutesUntilNext;

  RateLimitException(this.message, {this.minutesUntilNext});

  @override
  String toString() => message;
}
