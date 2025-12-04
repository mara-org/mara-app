# Frontend Service Level Objectives (SLOs)

## Overview

This document defines **client-side** SLOs and SLIs for the Mara mobile application. These metrics are based on client-side observability data from Sentry and Firebase Analytics.

**Note**: These SLOs are conceptual for now. Actual target numbers will be determined based on production data and business requirements.

## Service Level Indicators (SLIs)

### App Start Crash Rate

**Definition**: Percentage of app launches that result in a crash before the first screen is displayed.

**Measurement**:
- Source: Sentry/Firebase Crashlytics
- Metric: `crashes_on_startup / total_app_starts`
- Time window: 30 days rolling

**Current Target**: < 0.1% (1 in 1000 app starts)

**Future Target**: < 0.01% (1 in 10,000 app starts)

### App Foreground Crash Rate

**Definition**: Percentage of app sessions that experience a crash while the app is in the foreground.

**Measurement**:
- Source: Sentry/Firebase Crashlytics
- Metric: `crashes_in_foreground / total_sessions`
- Time window: 30 days rolling

**Current Target**: < 0.5% (5 in 1000 sessions)

**Future Target**: < 0.1% (1 in 1000 sessions)

### Screen Error Rate

**Definition**: Percentage of screen views that result in an error state (not a crash, but a recoverable error).

**Measurement**:
- Source: Sentry error events + Firebase Analytics
- Metric: `screen_errors / total_screen_views`
- Time window: 30 days rolling
- Error types: Network errors, API errors, UI errors

**Current Target**: < 2% (2 in 100 screen views)

**Future Target**: < 0.5% (1 in 200 screen views)

### Network Request Success Rate

**Definition**: Percentage of network requests that succeed (2xx status codes).

**Measurement**:
- Source: Dio interceptor logs or Sentry performance monitoring
- Metric: `successful_requests / total_requests`
- Time window: 30 days rolling
- Excludes: User-initiated cancellations

**Current Target**: > 95% (95% success rate)

**Future Target**: > 99% (99% success rate)

### App Cold Start Duration

**Definition**: Time from app launch to first interactive screen (cold start).

**Measurement**:
- Source: Firebase Analytics event `app_cold_start` (via `AnalyticsService.recordAppColdStart()`)
- Metric: P50 (median) and P95 (95th percentile) cold start duration
- Time window: 30 days rolling
- Implementation: Call `AnalyticsService.recordAppColdStart(durationMs: ...)` when first screen is ready

**Current Target**: 
- P50: < 2 seconds
- P95: < 3 seconds

**Future Target**: 
- P50: < 1 second
- P95: < 2 seconds

### Chat Screen Open Time

**Definition**: Time from navigation start to chat screen being fully interactive.

**Measurement**:
- Source: Firebase Analytics event `chat_screen_open` (via `AnalyticsService.recordChatScreenOpen()`)
- Metric: P50 (median) and P95 (95th percentile) chat screen open time
- Time window: 30 days rolling
- Implementation: Call `AnalyticsService.recordChatScreenOpen(durationMs: ...)` when chat screen is ready

**Current Target**: 
- P50: < 1 second
- P95: < 2 seconds

**Future Target**: 
- P50: < 500ms
- P95: < 1 second

## Service Level Objectives (SLOs)

### SLO 1: App Stability

**Objective**: 99.9% of app sessions complete without a crash.

**SLI**: App Foreground Crash Rate < 0.1%

**Measurement Period**: 30 days rolling

**Error Budget**: 0.1% of sessions can crash

### SLO 2: App Reliability

**Objective**: 98% of screen views complete without errors.

**SLI**: Screen Error Rate < 2%

**Measurement Period**: 30 days rolling

**Error Budget**: 2% of screen views can have errors

### SLO 3: Network Resilience

**Objective**: 95% of network requests succeed.

**SLI**: Network Request Success Rate > 95%

**Measurement Period**: 30 days rolling

**Error Budget**: 5% of requests can fail

### SLO 4: Performance

**Objective**: 95% of app cold starts complete in under 3 seconds.

**SLI**: App Cold Start Duration (P95) < 3 seconds

**Measurement Period**: 30 days rolling

**Error Budget**: 5% of cold starts can take longer

### SLO 5: Key Flow Success Rate

**Objective**: 98% of critical user flows complete successfully.

**SLIs**:
- Sign-in flow success rate > 98% (measured via `sign_in_flow` events)
- Chat start flow success rate > 98% (measured via `chat_start_flow` events)
- Message send success rate > 99% (measured via `message_send` events)

**Measurement Period**: 30 days rolling

**Error Budget**: 
- 2% of sign-in attempts can fail
- 2% of chat start attempts can fail
- 1% of message sends can fail

**Implementation**: 
- Call `AnalyticsService.recordSignInSuccess()` / `recordSignInFailure()` for sign-in flows
- Call `AnalyticsService.recordChatStartSuccess()` / `recordChatStartFailure()` for chat start flows
- Call `AnalyticsService.recordMessageSendSuccess()` / `recordMessageSendFailure()` for message sends

## Monitoring & Alerting

### Data Sources

1. **Sentry**:
   - Crash reports
   - Error events
   - Performance monitoring

2. **Firebase Analytics**:
   - User sessions
   - Screen views
   - Custom events

3. **Firebase Crashlytics**:
   - Crash reports (if enabled)

### Alerting Strategy

**Critical Alerts** (P0):
- App start crash rate > 1%
- App foreground crash rate > 1%
- Network success rate < 90%

**Warning Alerts** (P1):
- App start crash rate > 0.5%
- App foreground crash rate > 0.5%
- Screen error rate > 5%
- Network success rate < 95%

**Info Alerts** (P2):
- Performance degradation (P95 > target)
- Error rate trending upward

### Alert Channels

- **Discord**: `#mara-alerts` for critical alerts
- **Sentry**: Built-in alerting rules
- **Firebase**: Crashlytics alerts

## Error Budget Management

### Error Budget Consumption

When error budgets are consumed:

1. **< 50% consumed**: Normal operations
2. **50-75% consumed**: Review and optimize
3. **75-100% consumed**: Freeze new features, focus on stability
4. **> 100% consumed**: Incident response, post-mortem required

### Error Budget Recovery

- Error budgets reset monthly
- Historical data tracked for trend analysis
- Recovery actions documented in post-mortems

## Implementation Notes

### Current Status

- ✅ Observability infrastructure in place (Sentry/Firebase)
- ✅ Crash reporting configured with structured tags (environment, app_version, build_number, screen, feature, error_type)
- ✅ Analytics service abstraction created with SLO metrics methods
- ✅ Structured logging layer implemented (`Logger` class)
- ✅ SLO metrics tracking implemented:
  - `app_cold_start` - App cold start duration
  - `chat_screen_open` - Chat screen open time
  - `sign_in_flow` - Sign-in success/failure tracking
  - `chat_start_flow` - Chat start success/failure tracking
  - `message_send` - Message send success/failure tracking
- ⚠️ SLO targets are concrete but will be refined with production data
- ⚠️ Alerting rules need to be configured in Sentry/Firebase dashboards
- ⚠️ SLO metrics need to be called from relevant screens (see implementation notes below)

### Implementation Guide

#### App Cold Start Tracking

In `main.dart` or first screen's `initState()`:
```dart
final startTime = DateTime.now();
// ... app initialization ...
final durationMs = DateTime.now().difference(startTime).inMilliseconds;
AnalyticsService.recordAppColdStart(durationMs: durationMs);
```

#### Chat Screen Open Time Tracking

In chat screen's `initState()` or when screen becomes ready:
```dart
final startTime = DateTime.now();
// ... screen initialization ...
final durationMs = DateTime.now().difference(startTime).inMilliseconds;
AnalyticsService.recordChatScreenOpen(durationMs: durationMs);
```

#### Key Flow Success/Failure Tracking

**Sign-in Flow**:
```dart
final startTime = DateTime.now();
try {
  // ... sign-in logic ...
  final durationMs = DateTime.now().difference(startTime).inMilliseconds;
  AnalyticsService.recordSignInSuccess(method: 'email', durationMs: durationMs);
} catch (e) {
  final durationMs = DateTime.now().difference(startTime).inMilliseconds;
  AnalyticsService.recordSignInFailure(method: 'email', error: e.toString(), durationMs: durationMs);
}
```

**Chat Start Flow**:
```dart
final startTime = DateTime.now();
try {
  // ... start chat logic ...
  final durationMs = DateTime.now().difference(startTime).inMilliseconds;
  AnalyticsService.recordChatStartSuccess(durationMs: durationMs);
} catch (e) {
  final durationMs = DateTime.now().difference(startTime).inMilliseconds;
  AnalyticsService.recordChatStartFailure(error: e.toString(), durationMs: durationMs);
}
```

**Message Send**:
```dart
final startTime = DateTime.now();
try {
  // ... send message logic ...
  final durationMs = DateTime.now().difference(startTime).inMilliseconds;
  AnalyticsService.recordMessageSendSuccess(durationMs: durationMs);
} catch (e) {
  final durationMs = DateTime.now().difference(startTime).inMilliseconds;
  AnalyticsService.recordMessageSendFailure(error: e.toString(), durationMs: durationMs);
}
```

### Next Steps

1. **Integration**:
   - Add SLO metric calls to relevant screens and flows
   - Test metrics in debug mode to verify they're logged correctly
   - Verify metrics appear in Firebase Analytics dashboard

2. **Production Launch**:
   - Collect baseline metrics for 1-2 weeks
   - Refine SLO targets based on real data
   - Configure alerting rules in Firebase Analytics and Sentry

3. **Ongoing**:
   - Monitor SLO compliance weekly
   - Review error budgets monthly
   - Adjust targets based on business needs
   - Use structured logs (`Logger`) for debugging incidents

## Related Documentation

- [Architecture](ARCHITECTURE.md): System architecture overview
- [Incident Response](INCIDENT_RESPONSE.md): Incident handling procedures
- [README](../README.md): Project overview

## References

- [Google SRE Book: SLIs, SLOs, and SLAs](https://sre.google/workbook/slo/)
- [Sentry Performance Monitoring](https://docs.sentry.io/product/performance/)
- [Firebase Performance Monitoring](https://firebase.google.com/docs/perf-mon)

