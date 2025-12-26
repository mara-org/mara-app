import 'dart:collection';

/// Rate limiter for email-based requests (verification, password reset).
///
/// Limits requests to 5 per hour per email address to prevent abuse.
class EmailRateLimiter {
  // Maximum requests allowed per hour
  static const int _maxRequestsPerHour = 5;
  static const Duration _windowDuration = Duration(hours: 1);

  // Map of email -> list of request timestamps
  static final Map<String, Queue<DateTime>> _requestHistory = {};

  /// Check if a request can be made for the given email.
  static bool canMakeRequest(String email) {
    final normalizedEmail = email.toLowerCase().trim();
    final now = DateTime.now();
    final history = _requestHistory[normalizedEmail] ??= Queue<DateTime>();

    // Remove old requests outside the window
    while (
        history.isNotEmpty && now.difference(history.first) > _windowDuration) {
      history.removeFirst();
    }

    // Check if under limit
    return history.length < _maxRequestsPerHour;
  }

  /// Get minutes until the next request can be made.
  static int getMinutesUntilNextRequest(String email) {
    final normalizedEmail = email.toLowerCase().trim();
    final now = DateTime.now();
    final history = _requestHistory[normalizedEmail] ??= Queue<DateTime>();

    // Remove old requests outside the window
    while (
        history.isNotEmpty && now.difference(history.first) > _windowDuration) {
      history.removeFirst();
    }

    if (history.isEmpty) {
      return 0;
    }

    // Calculate when the oldest request will expire
    final oldestRequest = history.first;
    final timeUntilExpiry = _windowDuration - now.difference(oldestRequest);
    final minutes = timeUntilExpiry.inMinutes;
    return minutes > 0 ? minutes : 1; // At least 1 minute
  }

  /// Record a request for rate limiting.
  static void recordRequest(String email) {
    final normalizedEmail = email.toLowerCase().trim();
    final now = DateTime.now();
    final history = _requestHistory[normalizedEmail] ??= Queue<DateTime>();

    // Remove old requests outside the window
    while (
        history.isNotEmpty && now.difference(history.first) > _windowDuration) {
      history.removeFirst();
    }

    // Add new request
    history.add(now);
  }

  /// Reset rate limit for an email (useful for testing).
  static void reset(String email) {
    final normalizedEmail = email.toLowerCase().trim();
    _requestHistory.remove(normalizedEmail);
  }

  /// Reset all rate limits (useful for testing).
  static void resetAll() {
    _requestHistory.clear();
  }
}
