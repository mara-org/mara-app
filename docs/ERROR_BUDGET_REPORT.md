# Error Budget Report

This document tracks error budget consumption for the Mara mobile application based on client-side SLOs.

**Last Updated:** [Auto-updated monthly]

## Error Budget Overview

Error budgets represent the acceptable amount of "bad" events (crashes, errors, failures) before violating SLOs. When error budgets are consumed, we must focus on stability over new features.

## SLO 1: App Stability

**Objective:** 99.9% of app sessions complete without a crash

**SLI:** App Foreground Crash Rate < 0.1%

**Error Budget:** 0.1% of sessions can crash

### Current Status

| Period | Total Sessions | Crashes | Crash Rate | Budget Used | Budget Remaining |
|--------|---------------|---------|------------|-------------|------------------|
| Current Month | [TBD] | [TBD] | [TBD]% | [TBD]% | [TBD]% |
| Last Month | [TBD] | [TBD] | [TBD]% | [TBD]% | [TBD]% |

**Status:** ✅ Within Budget | ⚠️ Approaching Limit | ❌ Budget Exceeded

## SLO 2: App Reliability

**Objective:** 98% of screen views complete without errors

**SLI:** Screen Error Rate < 2%

**Error Budget:** 2% of screen views can have errors

### Current Status

| Period | Total Screen Views | Errors | Error Rate | Budget Used | Budget Remaining |
|--------|-------------------|--------|------------|-------------|------------------|
| Current Month | [TBD] | [TBD] | [TBD]% | [TBD]% | [TBD]% |
| Last Month | [TBD] | [TBD] | [TBD]% | [TBD]% | [TBD]% |

**Status:** ✅ Within Budget | ⚠️ Approaching Limit | ❌ Budget Exceeded

## SLO 3: Network Resilience

**Objective:** 95% of network requests succeed

**SLI:** Network Request Success Rate > 95%

**Error Budget:** 5% of requests can fail

### Current Status

| Period | Total Requests | Failures | Success Rate | Budget Used | Budget Remaining |
|--------|---------------|----------|--------------|-------------|------------------|
| Current Month | [TBD] | [TBD] | [TBD]% | [TBD]% | [TBD]% |
| Last Month | [TBD] | [TBD] | [TBD]% | [TBD]% | [TBD]% |

**Status:** ✅ Within Budget | ⚠️ Approaching Limit | ❌ Budget Exceeded

## SLO 4: Performance

**Objective:** 95% of app launches complete in under 3 seconds

**SLI:** App Cold Start Duration (P95) < 3 seconds

**Error Budget:** 5% of launches can take longer

### Current Status

| Period | Total Launches | P95 Duration | P95 > 3s | Budget Used | Budget Remaining |
|--------|---------------|--------------|----------|-------------|------------------|
| Current Month | [TBD] | [TBD]s | [TBD]% | [TBD]% | [TBD]% |
| Last Month | [TBD] | [TBD]s | [TBD]% | [TBD]% | [TBD]% |

**Status:** ✅ Within Budget | ⚠️ Approaching Limit | ❌ Budget Exceeded

## SLO 5: Key Flow Success Rate

**Objective:** 98% of critical user flows complete successfully

**SLIs:**
- Sign-in flow success rate > 98%
- Chat start flow success rate > 98%
- Message send success rate > 99%

### Sign-In Flow

| Period | Total Attempts | Failures | Success Rate | Budget Used | Budget Remaining |
|--------|---------------|----------|--------------|-------------|------------------|
| Current Month | [TBD] | [TBD] | [TBD]% | [TBD]% | [TBD]% |

**Status:** ✅ Within Budget | ⚠️ Approaching Limit | ❌ Budget Exceeded

### Chat Start Flow

| Period | Total Attempts | Failures | Success Rate | Budget Used | Budget Remaining |
|--------|---------------|----------|--------------|-------------|------------------|
| Current Month | [TBD] | [TBD] | [TBD]% | [TBD]% | [TBD]% |

**Status:** ✅ Within Budget | ⚠️ Approaching Limit | ❌ Budget Exceeded

### Message Send

| Period | Total Attempts | Failures | Success Rate | Budget Used | Budget Remaining |
|--------|---------------|----------|--------------|-------------|------------------|
| Current Month | [TBD] | [TBD] | [TBD]% | [TBD]% | [TBD]% |

**Status:** ✅ Within Budget | ⚠️ Approaching Limit | ❌ Budget Exceeded

## Error Budget Consumption Levels

### < 50% Consumed

**Status:** ✅ Normal Operations

**Actions:**
- Continue normal development
- Monitor trends
- Proactive improvements

### 50-75% Consumed

**Status:** ⚠️ Review and Optimize

**Actions:**
- Review error patterns
- Identify optimization opportunities
- Plan stability improvements
- Reduce new feature velocity slightly

### 75-100% Consumed

**Status:** 🔴 Freeze New Features

**Actions:**
- Focus on stability
- Fix existing bugs
- Optimize performance
- Postpone non-critical features

### > 100% Consumed

**Status:** 🚨 Incident Response Required

**Actions:**
- Immediate incident response
- Post-mortem required
- Stability fixes prioritized
- Feature freeze until recovery

## Error Budget Recovery

### Recovery Actions

When error budgets are consumed:

1. **Immediate:**
   - Investigate root causes
   - Deploy hotfixes
   - Rollback if necessary

2. **Short-term:**
   - Fix identified issues
   - Optimize performance
   - Improve error handling

3. **Long-term:**
   - Architectural improvements
   - Better testing
   - Performance optimization

### Budget Reset

- Error budgets reset monthly
- Historical data tracked for trend analysis
- Recovery actions documented in post-mortems

## Data Sources

### Metrics Collection

- **Crashes:** Sentry / Firebase Crashlytics
- **Errors:** Sentry error events
- **Performance:** Firebase Analytics SLO events
- **Flow Success:** Firebase Analytics custom events

### Calculation Script

A script can be created to automatically calculate error budgets from observability data:

```bash
# Example: Calculate error budget consumption
# scripts/calculate-error-budget.sh
```

## Monthly Review

### Review Process

1. **Collect Metrics:** From Sentry, Firebase dashboards
2. **Calculate Budgets:** Update this document
3. **Analyze Trends:** Identify patterns
4. **Plan Actions:** Based on budget consumption
5. **Document:** Update this report

### Review Checklist

- [ ] All SLO metrics collected
- [ ] Error budgets calculated
- [ ] Trends analyzed
- [ ] Actions planned
- [ ] Report updated
- [ ] Team notified if budget exceeded

## Related Documentation

- [Frontend SLOs](FRONTEND_SLOS.md): SLO definitions
- [Reliability Dashboards](RELIABILITY_DASHBOARDS.md): Dashboard setup
- [Observability Alerts](OBSERVABILITY_ALERTS.md): Alert rules

---

**Note:** This report will be populated with actual metrics once production data is available. For now, it serves as a template for error budget tracking.

