# Observability Alert Rules

This document defines alert rules for the Mara mobile application based on SLOs and key metrics.

**Note:** These are frontend-only metrics. Backend metrics are tracked separately.

## Alert Configuration

Alerts should be configured in:
- **Sentry:** Error and performance alerts
- **Firebase Crashlytics:** Crash rate alerts
- **Firebase Analytics:** Custom event alerts (if supported)
- **GitHub Actions:** CI/CD failure alerts

## Critical Alerts (P0)

### App Start Crash Rate > 1%

**Metric:** `crashes_on_startup / total_app_starts`

**Source:** Sentry / Firebase Crashlytics

**Threshold:** > 1% (1 in 100 app starts)

**Action:**
- Immediate investigation
- Check recent deployments
- Review crash reports in Sentry
- Consider rollback if recent deployment

**Alert Channel:** Discord `#mara-alerts`

### App Foreground Crash Rate > 1%

**Metric:** `crashes_in_foreground / total_sessions`

**Source:** Sentry / Firebase Crashlytics

**Threshold:** > 1% (1 in 100 sessions)

**Action:**
- Investigate crash patterns
- Check error tags (screen, feature, error_type)
- Review recent code changes
- Fix and deploy hotfix

**Alert Channel:** Discord `#mara-alerts`

### Network Success Rate < 90%

**Metric:** `successful_requests / total_requests`

**Source:** Sentry Performance / Dio interceptor logs

**Threshold:** < 90% success rate

**Action:**
- Check backend status (if available)
- Review network error patterns
- Check circuit breaker status
- Investigate API endpoint issues

**Alert Channel:** Discord `#mara-alerts`

## Warning Alerts (P1)

### App Start Crash Rate > 0.5%

**Metric:** `crashes_on_startup / total_app_starts`

**Threshold:** > 0.5% but ≤ 1%

**Action:**
- Monitor trend
- Investigate if trend continues upward
- Review crash reports

**Alert Channel:** Discord `#mara-alerts`

### App Foreground Crash Rate > 0.5%

**Metric:** `crashes_in_foreground / total_sessions`

**Threshold:** > 0.5% but ≤ 1%

**Action:**
- Monitor trend
- Investigate crash patterns
- Plan fix for next release

**Alert Channel:** Discord `#mara-alerts`

### Screen Error Rate > 5%

**Metric:** `screen_errors / total_screen_views`

**Source:** Sentry error events + Firebase Analytics

**Threshold:** > 5%

**Action:**
- Review error types (network/ui/data)
- Check affected screens
- Investigate root cause

**Alert Channel:** Discord `#mara-alerts`

### Network Success Rate < 95%

**Metric:** `successful_requests / total_requests`

**Threshold:** < 95% but ≥ 90%

**Action:**
- Monitor trend
- Review error patterns
- Investigate if trend continues

**Alert Channel:** Discord `#mara-alerts`

### Sign-In Flow Success Rate < 98%

**Metric:** `sign_in_flow` events with `success:false / total sign_in_flow events`

**Source:** Firebase Analytics

**Threshold:** < 98%

**Action:**
- Review sign-in error patterns
- Check authentication flow
- Investigate backend connectivity (if applicable)

**Alert Channel:** Discord `#mara-alerts`

### Chat Start Flow Success Rate < 98%

**Metric:** `chat_start_flow` events with `success:false / total chat_start_flow events`

**Source:** Firebase Analytics

**Threshold:** < 98%

**Action:**
- Review chat start errors
- Check network connectivity
- Investigate chat initialization

**Alert Channel:** Discord `#mara-alerts`

### Message Send Success Rate < 99%

**Metric:** `message_send` events with `success:false / total message_send events`

**Source:** Firebase Analytics

**Threshold:** < 99%

**Action:**
- Review message send errors
- Check network issues
- Investigate backend connectivity

**Alert Channel:** Discord `#mara-alerts`

## Info Alerts (P2)

### Performance Degradation

**Metrics:**
- App cold start P95 > 3 seconds
- Chat screen open P95 > 2 seconds
- Screen render P95 > 1 second

**Source:** Firebase Analytics SLO events

**Threshold:** P95 exceeds target

**Action:**
- Monitor trend
- Investigate if consistent
- Optimize if needed

**Alert Channel:** Discord `#mara-dev-events`

### Error Rate Trending Upward

**Metric:** Error rate increasing over 24-48 hours

**Source:** Sentry / Firebase Crashlytics

**Action:**
- Monitor closely
- Investigate if trend continues
- Plan fix

**Alert Channel:** Discord `#mara-dev-events`

## Alert Configuration Examples

### Sentry Alert Rules

```yaml
# Example Sentry alert configuration
rules:
  - name: High Crash Rate
    conditions:
      - metric: crash_rate
        threshold: 1.0
        window: 1h
    actions:
      - type: discord
        channel: mara-alerts
      - type: pagerduty
        severity: critical
```

### Firebase Crashlytics Alerts

Configure in Firebase Console:
- Crash-free users < 99%
- New crash types detected
- Crash rate spike (>20% increase)

### Firebase Analytics Alerts

Configure custom alerts for:
- `sign_in_flow` success rate
- `chat_start_flow` success rate
- `message_send` success rate

## Alert Response Procedures

### When Alert Fires

1. **Acknowledge:** Post in Discord `#mara-alerts`
2. **Investigate:** Use observability dashboards
3. **Mitigate:** Take immediate action if P0
4. **Document:** Update incident log
5. **Resolve:** Fix and verify
6. **Review:** Post-mortem for P0/P1

### False Positives

- Document false positive patterns
- Adjust alert thresholds if needed
- Update alert rules to reduce noise

## Alert Tuning

### Threshold Adjustment

- **Start Conservative:** Lower thresholds initially
- **Tune Based on Data:** Adjust after collecting baseline metrics
- **Reduce Noise:** Increase thresholds if too many false positives
- **Increase Sensitivity:** Lower thresholds if missing real issues

### Alert Fatigue Prevention

- **Prioritize:** Focus on P0/P1 alerts
- **Group:** Combine related alerts
- **Suppress:** Temporarily suppress known issues being worked on
- **Review:** Regularly review and tune alerts

## Monitoring Dashboards

### Sentry Dashboard

**Key Views:**
- Issues by error type
- Crash rate over time
- Affected users
- Performance metrics

**Filters:**
- `environment:production`
- `error_type:network|ui|data`
- `screen:chat_screen|auth_screen`

### Firebase Crashlytics Dashboard

**Key Views:**
- Crash-free users percentage
- Crashes by version
- Non-fatal errors
- Affected devices

### Firebase Analytics Dashboard

**Key Views:**
- Custom events (SLO metrics)
- User engagement
- Screen views
- Flow success rates

## Implementation Notes

### Current Status

- ✅ Alert infrastructure in place (Sentry, Firebase)
- ⚠️ Alert rules need manual configuration in SaaS dashboards
- ⚠️ Discord webhook integration configured
- ⚠️ PagerDuty/Opsgenie integration (to be configured)

### Next Steps

1. **Configure Sentry Alerts:**
   - Set up alert rules in Sentry dashboard
   - Configure Discord webhook integration
   - Test alert delivery

2. **Configure Firebase Alerts:**
   - Set up Crashlytics alerts
   - Configure Analytics custom alerts (if supported)
   - Test alert delivery

3. **Set Up On-Call:**
   - Configure PagerDuty/Opsgenie
   - Set up on-call rotation
   - Test escalation paths

## Related Documentation

- [Frontend SLOs](FRONTEND_SLOS.md): SLO definitions and targets
- [Incident Response](INCIDENT_RESPONSE.md): Incident handling procedures
- [On-Call Runbook](ONCALL.md): On-call responsibilities

