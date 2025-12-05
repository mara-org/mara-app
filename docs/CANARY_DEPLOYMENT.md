# Canary Deployment Guide

This document describes the canary deployment process for the Mara mobile application using feature flags.

## Overview

Canary deployments allow gradual rollout of new features to a small percentage of users, enabling safe testing in production before full release.

**Frontend-only:** Uses Firebase Remote Config for feature flag management.

## How It Works

1. **Feature Flag Setup:** Configure feature flag in Firebase Remote Config
2. **Gradual Rollout:** Start with 1% of users, gradually increase
3. **Monitoring:** Track metrics (crashes, errors, performance)
4. **Promotion:** Increase rollout if metrics are healthy
5. **Rollback:** Disable feature flag if issues detected

## Rollout Schedule

### Standard Canary Rollout

| Phase | Percentage | Duration | Promotion Criteria |
|-------|-----------|----------|-------------------|
| Phase 1 | 1% | 6 hours | No critical issues |
| Phase 2 | 2% | 6 hours | Metrics stable |
| Phase 3 | 5% | 6 hours | Metrics stable |
| Phase 4 | 25% | 12 hours | Metrics stable |
| Phase 5 | 50% | 12 hours | Metrics stable |
| Phase 6 | 100% | - | Full rollout |

### Fast Canary Rollout (Low Risk)

| Phase | Percentage | Duration | Promotion Criteria |
|-------|-----------|----------|-------------------|
| Phase 1 | 5% | 2 hours | No critical issues |
| Phase 2 | 25% | 4 hours | Metrics stable |
| Phase 3 | 100% | - | Full rollout |

## Monitoring Metrics

### Critical Metrics

Monitor these metrics during canary:

1. **Crash Rate**
   - Target: < 0.1%
   - Rollback if: > 0.5%

2. **Error Rate**
   - Target: < 2%
   - Rollback if: > 5%

3. **Performance**
   - App cold start P95: < 3s
   - Screen open P95: < 2s
   - Rollback if: > 20% degradation

4. **User Engagement**
   - Monitor feature usage
   - Check for negative trends

### Monitoring Tools

- **Sentry:** Crash and error tracking
- **Firebase Analytics:** User engagement metrics
- **Firebase Crashlytics:** Crash-free users percentage
- **Firebase Performance:** Performance metrics

## Rollout Process

### Step 1: Prepare Feature Flag

1. Create feature flag in Firebase Remote Config:
   ```json
   {
     "new_feature_enabled": {
       "defaultValue": false,
       "conditionalValues": {
         "percentage_1": true
       }
     }
   }
   ```

2. Implement feature flag check in code:
   ```dart
   final isEnabled = await featureFlagService.getBooleanFlag('new_feature_enabled');
   if (isEnabled) {
     // New feature code
   } else {
     // Old feature code
   }
   ```

### Step 2: Start Canary Deployment

Use GitHub Actions workflow:

```bash
# Manual trigger via GitHub Actions
# Or use script:
./scripts/canary-rollout.sh new_feature_enabled 1 staging false
```

### Step 3: Monitor Metrics

1. Check Sentry for crashes/errors
2. Monitor Firebase Analytics for engagement
3. Review performance metrics
4. Check user feedback

### Step 4: Promote or Rollback

**Promote to next phase if:**
- Crash rate < 0.1%
- Error rate < 2%
- Performance stable
- No critical user reports

**Rollback immediately if:**
- Crash rate > 0.5%
- Error rate > 5%
- Performance degradation > 20%
- Critical user-reported issues

### Step 5: Complete Rollout

Once at 100%:
1. Remove feature flag check (optional)
2. Remove old feature code
3. Document rollout completion

## Rollback Procedure

### Immediate Rollback

1. **Disable feature flag:**
   - Go to Firebase Console → Remote Config
   - Set feature flag to `false`
   - Publish configuration

2. **Verify rollback:**
   - Check metrics return to baseline
   - Confirm no new crashes/errors

3. **Document rollback:**
   - Create incident report
   - Document root cause
   - Plan fix for next release

### Automated Rollback

The canary deployment workflow can automatically rollback if:
- Crash rate exceeds threshold
- Error rate exceeds threshold
- Performance degradation detected

## Best Practices

### Feature Flag Naming

Use descriptive names:
- ✅ `new_chat_ui_enabled`
- ✅ `premium_features_enabled`
- ❌ `flag1`
- ❌ `test`

### Code Organization

1. **Keep feature flag checks minimal**
   ```dart
   // ✅ Good: Simple check
   if (await featureFlagService.getBooleanFlag('feature_enabled')) {
     return NewFeatureWidget();
   }
   return OldFeatureWidget();
   ```

2. **Remove feature flags after rollout**
   - Don't leave dead code
   - Clean up after full rollout

### Testing

1. **Test both variants**
   - Test with flag enabled
   - Test with flag disabled

2. **Test gradual rollout**
   - Verify percentage rollout works
   - Test rollback mechanism

## Example: Chat UI Redesign

### Setup

1. Create feature flag: `new_chat_ui_enabled`
2. Implement new UI behind flag
3. Keep old UI as fallback

### Rollout

1. **Phase 1 (1%):** Deploy to 1% of users
   - Monitor for 6 hours
   - Check crash/error rates

2. **Phase 2 (2%):** Increase to 2%
   - Monitor for 6 hours
   - Verify metrics stable

3. **Continue phases** until 100%

### Completion

1. Remove feature flag check
2. Remove old UI code
3. Document completion

## Troubleshooting

### Issue: Feature flag not working

**Check:**
- Firebase Remote Config published
- App version supports feature flag
- Feature flag name matches exactly

### Issue: Metrics not updating

**Check:**
- Firebase Analytics configured
- Sentry integration active
- Metrics collection enabled

### Issue: Rollback not working

**Check:**
- Feature flag disabled in Firebase
- App updated Remote Config
- No caching issues

## Related Documentation

- [Deployment Guide](DEPLOYMENT.md)
- [Feature Flags](../lib/core/feature_flags/README.md)
- [Frontend SLOs](FRONTEND_SLOS.md)
- [Incident Response](INCIDENT_RESPONSE.md)

---

**Last Updated:** December 2025

