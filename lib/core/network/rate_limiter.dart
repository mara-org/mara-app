/// Rate limiter for client-side request throttling
///
/// Prevents spamming the backend by limiting the number of requests
/// within a time window. Useful for chat messages, API calls, etc.
///
/// Usage:
/// ```dart
/// final rateLimiter = RateLimiter(
///   maxRequests: 10,
///   windowDuration: Duration(seconds: 60),
/// );
///
/// if (await rateLimiter.canMakeRequest('send_message')) {
///   // Make request
///   rateLimiter.recordRequest('send_message');
/// } else {
///   // Show rate limit error to user
/// }
/// ```
class RateLimiter {
  final int maxRequests;
  final Duration windowDuration;
  final Map<String, List<DateTime>> _requestHistory = {};

  RateLimiter({
    this.maxRequests = 10,
    this.windowDuration = const Duration(seconds: 60),
  });

  /// Check if a request can be made for the given action
  Future<bool> canMakeRequest(String action) async {
    final now = DateTime.now();
    final history = _requestHistory[action] ??= [];

    // Remove old requests outside the window
    history.removeWhere(
      (timestamp) => now.difference(timestamp) > windowDuration,
    );

    // Check if under limit
    return history.length < maxRequests;
  }

  /// Record a request for rate limiting
  void recordRequest(String action) {
    final now = DateTime.now();
    final history = _requestHistory[action] ??= [];
    history.add(now);

    // Clean up old entries periodically
    history.removeWhere(
      (timestamp) => now.difference(timestamp) > windowDuration,
    );
  }

  /// Get remaining requests in current window
  int getRemainingRequests(String action) {
    final now = DateTime.now();
    final history = _requestHistory[action] ??= [];

    // Remove old requests
    history.removeWhere(
      (timestamp) => now.difference(timestamp) > windowDuration,
    );

    return (maxRequests - history.length).clamp(0, maxRequests);
  }

  /// Reset rate limit for an action
  void reset(String action) {
    _requestHistory.remove(action);
  }

  /// Reset all rate limits
  void resetAll() {
    _requestHistory.clear();
  }
}
