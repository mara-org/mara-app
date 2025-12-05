#!/bin/bash
# Mara SRE – Error Budget Calculator
# Calculates error budget consumption from observability data
# Frontend-only: analyzes Sentry/Firebase metrics for error budgets

set -euo pipefail

# Configuration
DAYS="${1:-30}"
OUTPUT_FILE="${2:-docs/ERROR_BUDGET_REPORT.md}"

echo "📊 Calculating error budgets for last $DAYS days..."

# Calculate dates
END_DATE=$(date -u +"%Y-%m-%d")
START_DATE=$(date -u -d "$DAYS days ago" +"%Y-%m-%d")

echo "Time window: $START_DATE to $END_DATE"

# Placeholder for actual metrics calculation
# In production, this would query Sentry/Firebase APIs

cat > "$OUTPUT_FILE" << EOF
# Error Budget Report

**Generated:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")
**Time Window:** $START_DATE to $END_DATE ($DAYS days)

## SLO 1: App Stability

**Objective:** 99.9% of app sessions complete without a crash

| Period | Total Sessions | Crashes | Crash Rate | Budget Used | Budget Remaining |
|--------|---------------|---------|------------|-------------|------------------|
| Current Month | [TBD] | [TBD] | [TBD]% | [TBD]% | [TBD]% |

**Status:** ⚠️ Metrics collection pending

## SLO 2: App Reliability

**Objective:** 98% of screen views complete without errors

| Period | Total Screen Views | Errors | Error Rate | Budget Used | Budget Remaining |
|--------|-------------------|--------|------------|-------------|------------------|
| Current Month | [TBD] | [TBD] | [TBD]% | [TBD]% | [TBD]% |

**Status:** ⚠️ Metrics collection pending

## SLO 3: Network Resilience

**Objective:** 95% of network requests succeed

| Period | Total Requests | Failures | Success Rate | Budget Used | Budget Remaining |
|--------|---------------|----------|--------------|-------------|------------------|
| Current Month | [TBD] | [TBD] | [TBD]% | [TBD]% | [TBD]% |

**Status:** ⚠️ Metrics collection pending

## SLO 4: Performance

**Objective:** 95% of app launches complete in under 3 seconds

| Period | Total Launches | P95 Duration | P95 > 3s | Budget Used | Budget Remaining |
|--------|---------------|--------------|----------|-------------|------------------|
| Current Month | [TBD] | [TBD]s | [TBD]% | [TBD]% | [TBD]% |

**Status:** ⚠️ Metrics collection pending

## SLO 5: Key Flow Success Rate

### Sign-In Flow

| Period | Total Attempts | Failures | Success Rate | Budget Used | Budget Remaining |
|--------|---------------|----------|--------------|-------------|------------------|
| Current Month | [TBD] | [TBD] | [TBD]% | [TBD]% | [TBD]% |

**Status:** ⚠️ Metrics collection pending

### Chat Start Flow

| Period | Total Attempts | Failures | Success Rate | Budget Used | Budget Remaining |
|--------|---------------|----------|--------------|-------------|------------------|
| Current Month | [TBD] | [TBD] | [TBD]% | [TBD]% | [TBD]% |

**Status:** ⚠️ Metrics collection pending

### Message Send

| Period | Total Attempts | Failures | Success Rate | Budget Used | Budget Remaining |
|--------|---------------|----------|--------------|-------------|------------------|
| Current Month | [TBD] | [TBD] | [TBD]% | [TBD]% | [TBD]% |

**Status:** ⚠️ Metrics collection pending

---

**Note:** This report is a template. Actual metrics will be populated when:
1. Sentry API integration is configured
2. Firebase Analytics API integration is configured
3. Production data is available

See [docs/FRONTEND_SLOS.md](FRONTEND_SLOS.md) for SLO definitions.
EOF

echo "✅ Error budget report generated: $OUTPUT_FILE"
echo ""
echo "⚠️  Note: This is a template. Configure Sentry/Firebase API integration"
echo "   to populate actual metrics. See docs/FRONTEND_SLOS.md for details."

