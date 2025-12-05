#!/bin/bash
# Mara DevOps – Canary Rollout Script
# Manages gradual feature flag rollouts for canary deployments
# Frontend-only: updates Firebase Remote Config via API or generates config

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
FEATURE_FLAG_NAME="${1:-}"
ROLLOUT_PERCENT="${2:-1}"
ENVIRONMENT="${3:-staging}"
AUTO_PROMOTE="${4:-false}"

# Validate inputs
if [ -z "$FEATURE_FLAG_NAME" ]; then
  echo -e "${RED}❌ Error: Feature flag name is required${NC}"
  echo "Usage: $0 <feature_flag_name> <rollout_percent> [environment] [auto_promote]"
  exit 1
fi

if ! [[ "$ROLLOUT_PERCENT" =~ ^[0-9]+$ ]] || [ "$ROLLOUT_PERCENT" -lt 1 ] || [ "$ROLLOUT_PERCENT" -gt 100 ]; then
  echo -e "${RED}❌ Error: Rollout percentage must be between 1 and 100${NC}"
  exit 1
fi

echo -e "${GREEN}🚀 Starting canary rollout${NC}"
echo "Feature: $FEATURE_FLAG_NAME"
echo "Rollout: ${ROLLOUT_PERCENT}%"
echo "Environment: $ENVIRONMENT"
echo "Auto-promote: $AUTO_PROMOTE"
echo ""

# Create rollout plan
PLAN_FILE="canary-rollout-${FEATURE_FLAG_NAME}-$(date +%Y%m%d-%H%M%S).json"

cat > "$PLAN_FILE" << EOF
{
  "feature_flag": "${FEATURE_FLAG_NAME}",
  "environment": "${ENVIRONMENT}",
  "rollout_plan": {
    "phase_1": {
      "percentage": ${ROLLOUT_PERCENT},
      "duration_hours": 6,
      "status": "active"
    },
    "phase_2": {
      "percentage": $((ROLLOUT_PERCENT * 2)),
      "duration_hours": 12,
      "status": "pending"
    },
    "phase_3": {
      "percentage": $((ROLLOUT_PERCENT * 5)),
      "duration_hours": 18,
      "status": "pending"
    },
    "phase_4": {
      "percentage": 25,
      "duration_hours": 24,
      "status": "pending"
    },
    "phase_5": {
      "percentage": 50,
      "duration_hours": 48,
      "status": "pending"
    },
    "phase_6": {
      "percentage": 100,
      "duration_hours": 72,
      "status": "pending"
    }
  },
  "monitoring": {
    "crash_rate_threshold": 0.1,
    "error_rate_threshold": 2.0,
    "performance_degradation_threshold": 20
  },
  "started_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "auto_promote": ${AUTO_PROMOTE}
}
EOF

echo -e "${GREEN}✅ Rollout plan created: $PLAN_FILE${NC}"

# Generate Firebase Remote Config template
CONFIG_FILE="firebase-remote-config-${FEATURE_FLAG_NAME}.json"

cat > "$CONFIG_FILE" << EOF
{
  "parameters": {
    "${FEATURE_FLAG_NAME}": {
      "defaultValue": {
        "value": "false"
      },
      "valueType": "BOOLEAN",
      "conditionalValues": {
        "percentage_${ROLLOUT_PERCENT}": {
          "value": "true"
        }
      }
    }
  },
  "version": {
    "versionNumber": "1",
    "updateTime": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "updateUser": {
      "email": "ci@iammara.com"
    },
    "description": "Canary rollout for ${FEATURE_FLAG_NAME} at ${ROLLOUT_PERCENT}%"
  }
}
EOF

echo -e "${GREEN}✅ Firebase Remote Config template created: $CONFIG_FILE${NC}"

# Instructions
echo ""
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo "1. Review rollout plan: $PLAN_FILE"
echo "2. Apply Firebase Remote Config: $CONFIG_FILE"
echo "3. Monitor metrics for 6 hours"
echo "4. Proceed to Phase 2 if no issues detected"
echo ""
echo -e "${YELLOW}⚠️  Rollback Criteria:${NC}"
echo "- Crash rate > 0.5%"
echo "- Error rate > 5%"
echo "- Performance degradation > 20%"
echo "- Critical user-reported issues"
echo ""
echo -e "${GREEN}✅ Canary rollout initiated${NC}"

