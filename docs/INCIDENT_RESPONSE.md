# Incident Response Runbook

## Overview

This document outlines the incident response procedures for the Mara app. It provides step-by-step guidance for detecting, responding to, and resolving incidents.

## Incident Severity Levels

### P0 - Critical (Immediate Response)
- **Definition:** Complete service outage, data loss, security breach
- **Response Time:** Immediate (< 5 minutes)
- **Examples:**
  - App crashes for all users
  - Complete deployment failure
  - Security vulnerability exposed

### P1 - High (Urgent)
- **Definition:** Major feature broken, significant performance degradation
- **Response Time:** < 15 minutes
- **Examples:**
  - Critical feature unavailable
  - 50%+ of users affected
  - Repeated deployment failures

### P2 - Medium (Important)
- **Definition:** Minor feature broken, some users affected
- **Response Time:** < 1 hour
- **Examples:**
  - Non-critical feature unavailable
  - Performance issues affecting subset of users
  - CI failures blocking deployments

### P3 - Low (Normal)
- **Definition:** Cosmetic issues, minor bugs
- **Response Time:** < 4 hours
- **Examples:**
  - UI glitches
  - Minor performance issues
  - Non-blocking CI warnings

## Incident Detection Channels

### 1. Discord Alerts
- **Channel:** `#mara-alerts`
- **Triggers:**
  - Repeated CI failures
  - Deploy failures
  - Health check failures
  - Critical crashes (when implemented)

### 2. GitHub Actions
- **Location:** Repository → Actions tab
- **Check:** Failed workflow runs
- **Alerts:** Sent to Discord automatically

### 3. Crash Reports
- **Current:** Logged locally (console)
- **Future:** Backend endpoint → Discord `#mara-alerts`
- **Location:** `lib/core/utils/crash_reporter.dart`

## Incident Response Process

### Step 1: Acknowledge
1. Acknowledge the incident in Discord `#mara-alerts`
2. Assign yourself as incident responder
3. Post initial assessment

### Step 2: Assess
1. **Check Discord alerts** - Review recent alerts in `#mara-alerts`
2. **Check GitHub Actions** - Review failed workflow runs
3. **Check crash reports** - Review recent crashes (when backend is available)
4. **Determine severity** - Classify as P0/P1/P2/P3

### Step 3: Investigate
1. **Review logs:**
   - GitHub Actions logs
   - Crash reports (when available)
   - Discord notification history

2. **Identify root cause:**
   - Check recent deployments
   - Review recent code changes
   - Check for dependency issues
   - Verify external service status

### Step 4: Mitigate
1. **Immediate actions:**
   - Rollback deployment if needed
   - Disable affected feature if possible
   - Communicate status to team

2. **Document actions taken:**
   - Update Discord with status
   - Document in incident log

### Step 5: Resolve
1. **Fix the issue:**
   - Create fix PR
   - Test thoroughly
   - Deploy fix

2. **Verify resolution:**
   - Confirm alerts stop
   - Verify functionality restored
   - Monitor for 15-30 minutes

### Step 6: Post-Mortem
1. **Document incident:**
   - Root cause
   - Timeline
   - Impact
   - Resolution steps

2. **Improve processes:**
   - Update runbook if needed
   - Add monitoring if missing
   - Improve alerting if needed

## Common Incident Scenarios

### Scenario 1: CI Pipeline Failing Repeatedly

**Symptoms:**
- Multiple CI failures in Discord `#mara-dev-events`
- Repeated failures alert in `#mara-alerts`

**Response:**
1. Check GitHub Actions for error details
2. Review recent code changes
3. Check Flutter/Dart version compatibility
4. Verify dependencies (`pubspec.yaml`)
5. Fix linting/analysis errors
6. Re-run CI

**Prevention:**
- Run `flutter analyze` locally before pushing
- Run `flutter test` locally before pushing
- Use pre-commit hooks

### Scenario 2: Deployment Failure

**Symptoms:**
- Deploy failure notification in Discord `#mara-deploys`
- Build artifacts not created

**Response:**
1. Check deployment logs in GitHub Actions
2. Verify Flutter build succeeds locally
3. Check for version conflicts
4. Verify build configuration
5. Retry deployment
6. If persistent, rollback to last known good version

**Prevention:**
- Test builds locally before merging to main
- Use feature flags for risky changes
- Deploy during low-traffic periods

### Scenario 3: App Crashes (Future - When Backend Available)

**Symptoms:**
- Crash reports in Discord `#mara-alerts`
- User reports of app crashes

**Response:**
1. Review crash reports for patterns
2. Check device/OS distribution
3. Identify affected app version
4. Review recent code changes
5. Create hotfix if critical
6. Deploy fix via emergency release

**Prevention:**
- Comprehensive testing before release
- Beta testing program
- Crash reporting integration

### Scenario 4: Health Check Failure (Future - When Backend Available)

**Symptoms:**
- Health check alert in Discord `#mara-alerts`
- API endpoints not responding

**Response:**
1. Verify backend service status
2. Check database connectivity
3. Review backend logs
4. Check for resource exhaustion
5. Scale resources if needed
6. Restart services if needed

## Escalation Procedures

### Level 1: On-Call Engineer
- **Who:** Primary on-call engineer
- **Response:** Handle P2/P3 incidents, initial P1 assessment
- **Duration:** 4 hours

### Level 2: Senior Engineer / Tech Lead
- **Who:** Senior engineer or tech lead
- **Trigger:** P1 incidents, P0 initial response
- **Response:** < 15 minutes

### Level 3: Engineering Manager / CTO
- **Who:** Engineering manager or CTO
- **Trigger:** P0 incidents, unresolved P1 after 30 minutes
- **Response:** Immediate

## Communication Channels

### During Incident
- **Primary:** Discord `#mara-alerts` channel
- **Status Updates:** Post updates every 15 minutes
- **Resolution:** Post final resolution summary

### After Incident
- **Post-Mortem:** Document in GitHub Issues or wiki
- **Lessons Learned:** Share in team meeting
- **Process Updates:** Update this runbook

## Monitoring & Alerting

### Current Monitoring
- ✅ CI/CD pipeline status (Discord `#mara-dev-events`)
- ✅ Deployment status (Discord `#mara-deploys`)
- ✅ Repeated failures (Discord `#mara-alerts`)
- ✅ Crash reports (Sentry/Firebase Crashlytics)
- ✅ Error tracking (Sentry with structured tags)
- ✅ Performance metrics (Firebase Analytics SLO events)
- ✅ Structured logging (`Logger` class for debugging)
- ⚠️ Health checks (placeholder - needs backend)

### Using Observability Dashboards for Incident Debugging

#### Sentry Dashboard

**Access**: https://sentry.io/organizations/[org]/projects/[project]/

**Key Views for Incidents**:

1. **Issues Tab** - View all error reports
   - Filter by tags: `environment`, `app_version`, `build_number`, `screen`, `feature`, `error_type`
   - Example: Filter `error_type:network` to see all network-related errors
   - Example: Filter `screen:chat_screen` to see errors specific to chat

2. **Performance Tab** - View performance metrics
   - Track app cold start times
   - Monitor screen render times
   - Identify performance regressions

3. **Releases Tab** - Track errors by app version
   - Compare crash rates between versions
   - Identify regressions introduced in specific builds

**Debugging Workflow**:
1. Check Sentry Issues for recent errors matching incident symptoms
2. Filter by `environment:production` and `error_type` (network/ui/data/unknown)
3. Review error details: stack trace, tags (screen, feature), user context
4. Check if errors correlate with recent deployments (Releases tab)
5. Use structured tags to identify affected screens/features

**Example Query**:
```
environment:production AND error_type:network AND screen:chat_screen
```

#### Firebase Crashlytics Dashboard

**Access**: Firebase Console → Crashlytics

**Key Views for Incidents**:

1. **Crash-free users** - Overall app stability metric
   - Monitor crash-free rate (target: >99.9%)
   - Identify sudden drops indicating incidents

2. **Crashes Tab** - View crash reports
   - Filter by custom keys: `environment`, `app_version`, `build_number`, `screen`, `feature`, `error_type`
   - View crash trends over time
   - See affected devices and OS versions

3. **Non-fatal errors** - Recoverable errors
   - Track non-fatal errors by screen/feature
   - Identify error patterns

**Debugging Workflow**:
1. Check Crash-free users graph for sudden drops
2. Filter crashes by custom keys (e.g., `screen:chat_screen`)
3. Review crash details: stack trace, device info, user steps
4. Check if crashes correlate with specific app versions
5. Use custom keys to identify affected features

**Example Filter**:
- Custom Key: `screen` = `chat_screen`
- Custom Key: `error_type` = `network`

#### Firebase Analytics Dashboard

**Access**: Firebase Console → Analytics

**Key Views for Incidents**:

1. **Events Tab** - View custom events
   - Monitor SLO metrics: `app_cold_start`, `chat_screen_open`
   - Track flow success rates: `sign_in_flow`, `chat_start_flow`, `message_send`
   - Filter by event parameters (success, error, duration_ms)

2. **DebugView** (Development) - Real-time event monitoring
   - See events as they happen in debug builds
   - Useful for testing and debugging

**Debugging Workflow**:
1. Check `sign_in_flow` events for sign-in failures
   - Filter `success:false` to see failures
   - Check `error` parameter for failure reasons
   - Review `duration_ms` to identify slow flows

2. Check `chat_start_flow` events for chat start issues
   - Filter `success:false` to see failures
   - Review error patterns

3. Check `message_send` events for message sending issues
   - Filter `success:false` to see failures
   - Identify network vs. data errors

4. Monitor `app_cold_start` for performance issues
   - Check P95 duration_ms values
   - Identify performance regressions

**Example Queries**:
- `sign_in_flow` where `success:false` - Sign-in failures
- `chat_start_flow` where `success:false` - Chat start failures
- `message_send` where `success:false` - Message send failures
- `app_cold_start` where `duration_ms > 3000` - Slow app starts

#### Structured Logs (Logger)

**Access**: Console logs (debug builds) or log aggregation service (if configured)

**Key Information**:
- Structured logs include: screen, feature, log level, session_id, app_version
- Use logs to trace user flows and identify where errors occur
- Logs never contain sensitive health data (per design)

**Debugging Workflow**:
1. Search logs by `screen` or `feature` to trace user flow
2. Use `session_id` to correlate logs from same user session
3. Filter by log level (`ERROR`, `WARNING`, `INFO`) to find issues
4. Review timestamps to understand sequence of events

**Example Log Search**:
```
screen:chat_screen AND level:ERROR
```

### Alert Thresholds
- **Repeated Failures:** 3+ failures OR 2+ consecutive failures
- **Deploy Failures:** Any failure triggers alert
- **Crash Rate:** > 1% crash-free users drop triggers alert
- **SLO Violations:** 
  - App cold start P95 > 3 seconds
  - Sign-in flow success rate < 98%
  - Chat start flow success rate < 98%
  - Message send success rate < 99%

### Alert Thresholds
- **Repeated Failures:** 3+ failures OR 2+ consecutive failures
- **Deploy Failures:** Any failure triggers alert
- **Health Checks:** Any failure triggers alert (when implemented)
- **Crashes:** Critical crashes trigger alert (when implemented)

## On-Call Rotation

**Current Status:** Not yet implemented

**Recommended Setup:**
- Rotate weekly
- Primary + backup on-call
- Escalation path defined
- Handoff procedures documented

## Tools & Resources

### Discord Channels
- `#mara-deploys` - Deployment notifications
- `#mara-dev-events` - CI, PR, issue notifications
- `#mara-alerts` - Critical alerts and incidents
- `#mara-crashes` - Crash reports (future)

### GitHub
- Actions: `https://github.com/mara-org/mara-app/actions`
- Issues: `https://github.com/mara-org/mara-app/issues`
- Releases: `https://github.com/mara-org/mara-app/releases`

### Documentation
- This runbook: `docs/INCIDENT_RESPONSE.md`
- Enterprise Audit Report: [docs/ENTERPRISE_AUDIT_REPORT.md](ENTERPRISE_AUDIT_REPORT.md)
- README: `README.md`

## Contact Information

**Team Discord:** [Your Discord Server]  
**GitHub Repository:** https://github.com/mara-org/mara-app  
**Emergency Contact:** [To be configured]

---

**Last Updated:** 2025-12-03  
**Next Review:** 2026-01-03

