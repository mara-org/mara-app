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

### App Load Time (P50)

**Definition**: Median time from app launch to first interactive screen.

**Measurement**:
- Source: Sentry performance monitoring or Firebase Performance
- Metric: P50 (median) app load time
- Time window: 30 days rolling

**Current Target**: < 2 seconds

**Future Target**: < 1 second

### Screen Render Time (P95)

**Definition**: 95th percentile time to render a screen after navigation.

**Measurement**:
- Source: Sentry performance monitoring
- Metric: P95 screen render time
- Time window: 30 days rolling

**Current Target**: < 1 second

**Future Target**: < 500ms

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

**Objective**: 95% of app launches complete in under 2 seconds.

**SLI**: App Load Time (P95) < 2 seconds

**Measurement Period**: 30 days rolling

**Error Budget**: 5% of launches can take longer

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
- ✅ Crash reporting configured
- ✅ Analytics service abstraction created
- ⚠️ SLO targets are conceptual (will be refined with production data)
- ⚠️ Alerting rules need to be configured in Sentry/Firebase dashboards

### Next Steps

1. **Production Launch**:
   - Collect baseline metrics
   - Refine SLO targets based on real data
   - Configure alerting rules

2. **Ongoing**:
   - Monitor SLO compliance
   - Review error budgets monthly
   - Adjust targets based on business needs

## Related Documentation

- [Architecture](ARCHITECTURE.md): System architecture overview
- [Incident Response](INCIDENT_RESPONSE.md): Incident handling procedures
- [README](../README.md): Project overview

## References

- [Google SRE Book: SLIs, SLOs, and SLAs](https://sre.google/workbook/slo/)
- [Sentry Performance Monitoring](https://docs.sentry.io/product/performance/)
- [Firebase Performance Monitoring](https://firebase.google.com/docs/perf-mon)

