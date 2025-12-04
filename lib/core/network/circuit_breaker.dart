import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Circuit breaker pattern for network requests
///
/// Prevents repeated calls to failing endpoints by temporarily "opening" the circuit
/// after a threshold of failures. Once open, requests fail fast without attempting
/// the actual network call.
///
/// Usage:
/// ```dart
/// final circuitBreaker = CircuitBreaker(
///   failureThreshold: 5,
///   resetTimeout: Duration(seconds: 60),
/// );
/// ```
class CircuitBreaker {
  final int failureThreshold;
  final Duration resetTimeout;
  final Map<String, _CircuitState> _circuits = {};

  CircuitBreaker({
    this.failureThreshold = 5,
    this.resetTimeout = const Duration(seconds: 60),
  });

  /// Check if circuit is open for a given endpoint
  bool isOpen(String endpoint) {
    final state = _circuits[endpoint];
    if (state == null) return false;

    if (state.isOpen) {
      // Check if reset timeout has passed
      final now = DateTime.now();
      if (now.difference(state.lastFailure) > resetTimeout) {
        // Reset circuit
        _circuits[endpoint] = _CircuitState();
        if (kDebugMode) {
          debugPrint('Circuit breaker reset for: $endpoint');
        }
        return false;
      }
      return true;
    }

    return false;
  }

  /// Record a successful request
  void recordSuccess(String endpoint) {
    final state = _circuits[endpoint];
    if (state != null) {
      state.failureCount = 0;
      state.isOpen = false;
    }
  }

  /// Record a failed request
  void recordFailure(String endpoint) {
    final state = _circuits[endpoint] ??= _CircuitState();
    state.failureCount++;
    state.lastFailure = DateTime.now();

    if (state.failureCount >= failureThreshold) {
      state.isOpen = true;
      if (kDebugMode) {
        debugPrint(
          'Circuit breaker opened for: $endpoint (${state.failureCount} failures)',
        );
      }
    }
  }

  /// Reset circuit for an endpoint
  void reset(String endpoint) {
    _circuits.remove(endpoint);
  }

  /// Reset all circuits
  void resetAll() {
    _circuits.clear();
  }
}

class _CircuitState {
  int failureCount = 0;
  bool isOpen = false;
  DateTime lastFailure = DateTime.now();
}
