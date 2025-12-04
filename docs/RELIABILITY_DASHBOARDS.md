# Reliability Dashboards

This document describes the reliability dashboards to be built in Sentry, Firebase Crashlytics, and Firebase Analytics for client-side metrics.

**Note:** These dashboards are conceptual and describe what should be configured in the SaaS observability tools. Actual dashboard configuration is done in the respective tool interfaces.

## Dashboard Overview

Reliability dashboards provide real-time visibility into app health, performance, and error rates. All metrics are **client-side only** - backend metrics are tracked separately.

## Sentry Dashboard

### Key Metrics

1. **Crash-Free Users**
   - Metric: `(total_users - users_with_crashes) / total_users * 100`
   - Target: > 99.9%
   - Time Window: 30 days rolling

2. **Error Rate by Type**
   - Network errors
   - UI errors
   - Data errors
   - Unknown errors
   - Grouped by `error_type` tag

3. **Errors by Screen**
   - Filter by `screen` tag
   - Identify problematic screens
   - Track screen-specific error rates

4. **Errors by Feature**
   - Filter by `feature` tag
   - Identify problematic features
   - Track feature-specific error rates

5. **Performance Metrics**
   - App cold start duration (P50, P95, P99)
   - Screen render times
   - API response times (when backend available)

6. **Error Trends**
   - Error rate over time
   - Crash rate over time
   - Performance degradation trends

### Dashboard Views

**View 1: Overview**
- Crash-free users percentage
- Total errors (last 24h)
- Top error types
- Performance summary

**View 2: Errors by Category**
- Network errors
- UI errors
- Data errors
- Error rate trends

**View 3: Performance**
- App cold start (P50/P95/P99)
- Screen render times
- API latency (when available)

**View 4: Releases**
- Errors by app version
- Crash rate by version
- Performance by version

## Firebase Crashlytics Dashboard

### Key Metrics

1. **Crash-Free Users**
   - Primary metric for app stability
   - Target: > 99.9%
   - Tracked over 30 days

2. **Crashes by Version**
   - Identify problematic versions
   - Track version-specific crash rates
   - Compare versions

3. **Non-Fatal Errors**
   - Recoverable errors
   - Error patterns
   - Affected users

4. **Crash Trends**
   - Crash rate over time
   - New crash types
   - Crash frequency

### Dashboard Views

**View 1: Stability Overview**
- Crash-free users percentage
- Total crashes (last 24h)
- Top crash types
- Affected devices

**View 2: Version Analysis**
- Crashes by app version
- Crash-free rate by version
- Version comparison

**View 3: Device/OS Analysis**
- Crashes by device model
- Crashes by OS version
- Device-specific issues

## Firebase Analytics Dashboard

### Key Metrics

1. **SLO Metrics**
   - App cold start duration (from `app_cold_start` event)
   - Chat screen open time (from `chat_screen_open` event)
   - P50, P95, P99 percentiles

2. **Flow Success Rates**
   - Sign-in flow success rate (from `sign_in_flow` events)
   - Chat start flow success rate (from `chat_start_flow` events)
   - Message send success rate (from `message_send` events)

3. **User Engagement**
   - Daily active users
   - Session duration
   - Screen views
   - Feature usage

4. **Performance Trends**
   - Cold start time trends
   - Screen open time trends
   - Performance degradation detection

### Dashboard Views

**View 1: SLO Compliance**
- App cold start (P50/P95) vs target
- Chat screen open (P50/P95) vs target
- Flow success rates vs targets
- Error budget consumption

**View 2: User Flows**
- Sign-in flow success/failure
- Chat start flow success/failure
- Message send success/failure
- Flow duration metrics

**View 3: Performance**
- Performance metrics over time
- Performance by app version
- Performance regression detection

## Custom Dashboard Queries

### Sentry Queries

**High Crash Rate:**
```
environment:production AND error_type:crash AND crash_rate > 1%
```

**Network Errors:**
```
environment:production AND error_type:network AND screen:chat_screen
```

**Performance Issues:**
```
environment:production AND transaction.duration > 3000ms
```

### Firebase Analytics Queries

**Sign-In Failures:**
```
Event: sign_in_flow
Filter: success = false
Group by: error, method
```

**Slow Cold Starts:**
```
Event: app_cold_start
Filter: duration_ms > 3000
Group by: app_version
```

**Chat Start Failures:**
```
Event: chat_start_flow
Filter: success = false
Group by: error
```

## Dashboard Configuration

### Sentry Dashboard Setup

1. **Create Dashboard:**
   - Go to Sentry → Dashboards
   - Create new dashboard: "Mara App Reliability"

2. **Add Widgets:**
   - Crash-free users widget
   - Error rate by type widget
   - Performance metrics widget
   - Error trends widget

3. **Configure Filters:**
   - Default: `environment:production`
   - Time range: Last 30 days
   - Group by: `error_type`, `screen`, `feature`

### Firebase Dashboard Setup

1. **Crashlytics Dashboard:**
   - Go to Firebase Console → Crashlytics
   - View crash-free users graph
   - Configure alerts for thresholds

2. **Analytics Dashboard:**
   - Go to Firebase Console → Analytics
   - Create custom reports for SLO metrics
   - Set up event-based metrics

## Metrics to Track

### Availability Metrics

- **Crash-Free Users:** > 99.9%
- **Error Rate:** < 0.1%
- **Screen Error Rate:** < 2%

### Performance Metrics

- **App Cold Start P50:** < 2s
- **App Cold Start P95:** < 3s
- **Chat Screen Open P50:** < 1s
- **Chat Screen Open P95:** < 2s

### Reliability Metrics

- **Sign-In Success Rate:** > 98%
- **Chat Start Success Rate:** > 98%
- **Message Send Success Rate:** > 99%
- **Network Success Rate:** > 95%

## Error Budget Tracking

### Error Budget Calculation

**App Stability Error Budget:**
- SLO: 99.9% crash-free users
- Error Budget: 0.1% of sessions can crash
- Monthly Budget: ~0.1% of monthly sessions

**Flow Success Error Budget:**
- SLO: 98% sign-in success
- Error Budget: 2% of sign-in attempts can fail
- Monthly Budget: ~2% of monthly sign-in attempts

### Dashboard Widgets

- Error budget consumed (%)
- Error budget remaining (%)
- Error budget burn rate
- Projected budget exhaustion date

## Implementation Status

### Current Status

- ✅ Observability infrastructure in place
- ✅ Metrics being collected (Sentry, Firebase)
- ⚠️ Dashboards need manual configuration in SaaS tools
- ⚠️ Error budget tracking needs implementation

### Next Steps

1. **Configure Sentry Dashboard:**
   - Create reliability dashboard
   - Add key metric widgets
   - Set up filters and groupings

2. **Configure Firebase Dashboards:**
   - Set up Crashlytics views
   - Create Analytics custom reports
   - Configure SLO metric tracking

3. **Implement Error Budget Tracking:**
   - Calculate error budgets
   - Create error budget dashboard widgets
   - Set up error budget alerts

## Related Documentation

- [Frontend SLOs](FRONTEND_SLOS.md): SLO definitions
- [Observability Alerts](OBSERVABILITY_ALERTS.md): Alert rules
- [Incident Response](INCIDENT_RESPONSE.md): Incident procedures

