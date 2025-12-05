# A/B Testing Guide

This document describes the A/B testing infrastructure and process for the Mara mobile application.

## Overview

A/B testing allows comparing two variants of a feature to determine which performs better. We use Firebase Remote Config for A/B test management.

**Frontend-only:** All A/B testing is client-side using feature flags.

## How It Works

1. **Create Test:** Define test variants and percentages
2. **Implement Variants:** Code both A and B variants
3. **Configure Remote Config:** Set up percentage distribution
4. **Run Test:** Collect metrics for both variants
5. **Analyze Results:** Determine winning variant
6. **Implement Winner:** Roll out winning variant to 100%

## Test Setup

### Step 1: Define Test Hypothesis

Example:
- **Hypothesis:** New chat UI increases user engagement
- **Variant A:** Current chat UI (control)
- **Variant B:** New chat UI (treatment)
- **Success Metric:** Messages sent per session
- **Sample Size:** 10,000 users per variant
- **Duration:** 2 weeks

### Step 2: Implement Variants

```dart
// Get A/B test variant
final variant = await featureFlagService.getABTestVariant('chat_ui_test');

if (variant == 'A') {
  // Control: Current UI
  return CurrentChatWidget();
} else if (variant == 'B') {
  // Treatment: New UI
  return NewChatWidget();
}
```

### Step 3: Configure Firebase Remote Config

1. Go to Firebase Console → Remote Config
2. Create parameter: `ab_test_chat_ui`
3. Set conditional values:
   - Variant A: 50% of users
   - Variant B: 50% of users

### Step 4: Track Metrics

```dart
// Track test assignment
AnalyticsService.logEvent('ab_test_assigned', {
  'test_name': 'chat_ui_test',
  'variant': variant,
});

// Track success metric
AnalyticsService.logEvent('messages_sent', {
  'test_name': 'chat_ui_test',
  'variant': variant,
  'count': messageCount,
});
```

## Test Design

### Variant Distribution

Common distributions:
- **50/50:** Equal split (most common)
- **80/20:** More users in control
- **90/10:** Very conservative test

### Sample Size Calculation

Use statistical power analysis:
- **Power:** 80% (standard)
- **Significance Level:** 5% (p < 0.05)
- **Effect Size:** Minimum detectable difference

Example: To detect 10% increase in engagement:
- Need ~10,000 users per variant
- Duration: ~2 weeks (depending on traffic)

### Success Criteria

Define before starting test:
- **Primary Metric:** What you're optimizing for
- **Secondary Metrics:** Other important metrics
- **Guardrail Metrics:** Metrics that shouldn't degrade

Example:
- **Primary:** Messages sent per session (+10% target)
- **Secondary:** Session duration, user retention
- **Guardrail:** Crash rate, error rate (must not increase)

## Running Tests

### Using GitHub Actions

```bash
# Trigger A/B test workflow
# Via GitHub Actions UI or API
```

### Manual Setup

1. Configure Firebase Remote Config
2. Deploy app with A/B test code
3. Monitor metrics in Firebase Analytics
4. Analyze results after test period

## Analyzing Results

### Statistical Significance

Use statistical tests:
- **T-test:** For continuous metrics (e.g., session duration)
- **Chi-square:** For categorical metrics (e.g., conversion rate)
- **Confidence Interval:** 95% standard

### Example Analysis

```
Variant A (Control):
- Messages per session: 5.2
- Sample size: 10,000

Variant B (Treatment):
- Messages per session: 5.8
- Sample size: 10,000

Result: +11.5% increase (statistically significant, p < 0.05)
Winner: Variant B
```

### Guardrail Check

Verify guardrail metrics didn't degrade:
- Crash rate: Same or better
- Error rate: Same or better
- Performance: Same or better

## Implementing Winner

### Step 1: Verify Results

- Statistical significance confirmed
- Guardrail metrics stable
- Business impact positive

### Step 2: Roll Out Winner

1. Set variant B to 100% in Remote Config
2. Remove variant A code (optional)
3. Remove A/B test code (optional)

### Step 3: Monitor

- Watch metrics for 24-48 hours
- Verify no issues with full rollout
- Document results

## Best Practices

### Test Design

1. **One variable at a time**
   - Don't test multiple changes simultaneously
   - Isolate the variable being tested

2. **Clear hypothesis**
   - Define what you're testing
   - Define success criteria upfront

3. **Adequate sample size**
   - Use power analysis
   - Don't end test too early

### Implementation

1. **Clean code**
   - Keep A/B test logic simple
   - Don't pollute codebase with test code

2. **Proper tracking**
   - Track test assignment
   - Track all relevant metrics
   - Include variant in all events

3. **Test both variants**
   - Manually test variant A
   - Manually test variant B
   - Verify both work correctly

### Analysis

1. **Wait for significance**
   - Don't end test prematurely
   - Wait for adequate sample size

2. **Check guardrails**
   - Verify no negative impacts
   - Check all secondary metrics

3. **Document results**
   - Record test details
   - Share learnings with team

## Common Pitfalls

### Pitfall 1: Testing Too Early

**Problem:** Ending test before statistical significance

**Solution:** Use power analysis to determine sample size, wait for adequate data

### Pitfall 2: Multiple Variables

**Problem:** Testing multiple changes at once

**Solution:** Test one variable at a time, isolate changes

### Pitfall 3: Ignoring Guardrails

**Problem:** Focusing only on primary metric

**Solution:** Monitor all metrics, check guardrails before declaring winner

### Pitfall 4: Sample Size Mismatch

**Problem:** Unequal sample sizes between variants

**Solution:** Ensure equal distribution, check assignment logic

## Example Tests

### Test 1: Chat UI Redesign

- **Hypothesis:** New UI increases engagement
- **Variants:** Current UI vs New UI
- **Metric:** Messages sent per session
- **Result:** +15% increase, Variant B wins

### Test 2: Onboarding Flow

- **Hypothesis:** Shorter onboarding increases completion
- **Variants:** 5-step vs 3-step onboarding
- **Metric:** Onboarding completion rate
- **Result:** +8% increase, Variant B wins

### Test 3: Home Screen Layout

- **Hypothesis:** New layout increases feature discovery
- **Variants:** Grid vs List layout
- **Metric:** Feature usage rate
- **Result:** No significant difference, keep current

## Tools and Resources

- **Firebase Remote Config:** Feature flag management
- **Firebase Analytics:** Metric tracking
- **Statistical Calculator:** Sample size calculation
- **A/B Testing Calculator:** Statistical significance

## Related Documentation

- [Canary Deployment](CANARY_DEPLOYMENT.md)
- [Feature Flags](../lib/core/feature_flags/README.md)
- [Analytics Service](../lib/core/analytics/analytics_service.dart)

---

**Last Updated:** December 2025

