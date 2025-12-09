#!/bin/bash
# Mara App Size Monitor
# Monitors APK/AAB size and alerts on increases
# Frontend-only: analyzes Flutter build artifacts

set -euo pipefail

# Configuration
APK_PATH="${1:-build/app/outputs/flutter-apk/app-release.apk}"
AAB_PATH="${2:-build/app/outputs/bundle/release/app-release.aab}"
THRESHOLD_INCREASE_PERCENT="${3:-5}"  # Alert if size increases by 5% or more
THRESHOLD_ABSOLUTE_MB="${4:-10}"  # Alert if size exceeds 10MB increase

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "📦 Monitoring app size..."

# Function to get file size in MB
get_size_mb() {
  local file="$1"
  if [ -f "$file" ]; then
    # Get size in bytes, convert to MB
    local size_bytes=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
    echo "scale=2; $size_bytes / 1024 / 1024" | bc
  else
    echo "0"
  fi
}

# Function to get file size in bytes
get_size_bytes() {
  local file="$1"
  if [ -f "$file" ]; then
    stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0"
  else
    echo "0"
  fi
}

# Check if files exist
APK_EXISTS=false
AAB_EXISTS=false

if [ -f "$APK_PATH" ]; then
  APK_EXISTS=true
  APK_SIZE_MB=$(get_size_mb "$APK_PATH")
  APK_SIZE_BYTES=$(get_size_bytes "$APK_PATH")
  echo "✅ APK found: ${APK_SIZE_MB} MB"
else
  echo "⚠️  APK not found: $APK_PATH"
fi

if [ -f "$AAB_PATH" ]; then
  AAB_EXISTS=true
  AAB_SIZE_MB=$(get_size_mb "$AAB_PATH")
  AAB_SIZE_BYTES=$(get_size_bytes "$AAB_PATH")
  echo "✅ AAB found: ${AAB_SIZE_MB} MB"
else
  echo "⚠️  AAB not found: $AAB_PATH"
fi

if [ "$APK_EXISTS" = "false" ] && [ "$AAB_EXISTS" = "false" ]; then
  echo "❌ No build artifacts found. Cannot monitor app size."
  exit 1
fi

# Get baseline sizes from previous build (stored in GitHub Actions artifacts or cache)
BASELINE_APK_SIZE="${BASELINE_APK_SIZE:-0}"
BASELINE_AAB_SIZE="${BASELINE_AAB_SIZE:-0}"

# Calculate size changes
if [ "$APK_EXISTS" = "true" ] && [ "$BASELINE_APK_SIZE" != "0" ]; then
  APK_INCREASE=$(echo "scale=2; $APK_SIZE_MB - $BASELINE_APK_SIZE" | bc)
  APK_INCREASE_PERCENT=$(echo "scale=2; ($APK_INCREASE / $BASELINE_APK_SIZE) * 100" | bc)
  
  echo ""
  echo "📊 APK Size Analysis:"
  echo "  Current: ${APK_SIZE_MB} MB"
  echo "  Baseline: ${BASELINE_APK_SIZE} MB"
  echo "  Change: ${APK_INCREASE} MB (${APK_INCREASE_PERCENT}%)"
  
  # Check thresholds
  APK_ALERT=false
  if (( $(echo "$APK_INCREASE_PERCENT > $THRESHOLD_INCREASE_PERCENT" | bc -l) )); then
    echo -e "${RED}⚠️  ALERT: APK size increased by ${APK_INCREASE_PERCENT}% (threshold: ${THRESHOLD_INCREASE_PERCENT}%)${NC}"
    APK_ALERT=true
  fi
  
  if (( $(echo "$APK_INCREASE > $THRESHOLD_ABSOLUTE_MB" | bc -l) )); then
    echo -e "${RED}⚠️  ALERT: APK size increased by ${APK_INCREASE} MB (threshold: ${THRESHOLD_ABSOLUTE_MB} MB)${NC}"
    APK_ALERT=true
  fi
  
  if [ "$APK_ALERT" = "false" ]; then
    echo -e "${GREEN}✅ APK size within acceptable limits${NC}"
  fi
fi

if [ "$AAB_EXISTS" = "true" ] && [ "$BASELINE_AAB_SIZE" != "0" ]; then
  AAB_INCREASE=$(echo "scale=2; $AAB_SIZE_MB - $BASELINE_AAB_SIZE" | bc)
  AAB_INCREASE_PERCENT=$(echo "scale=2; ($AAB_INCREASE / $BASELINE_AAB_SIZE) * 100" | bc)
  
  echo ""
  echo "📊 AAB Size Analysis:"
  echo "  Current: ${AAB_SIZE_MB} MB"
  echo "  Baseline: ${BASELINE_AAB_SIZE} MB"
  echo "  Change: ${AAB_INCREASE} MB (${AAB_INCREASE_PERCENT}%)"
  
  # Check thresholds
  AAB_ALERT=false
  if (( $(echo "$AAB_INCREASE_PERCENT > $THRESHOLD_INCREASE_PERCENT" | bc -l) )); then
    echo -e "${RED}⚠️  ALERT: AAB size increased by ${AAB_INCREASE_PERCENT}% (threshold: ${THRESHOLD_INCREASE_PERCENT}%)${NC}"
    AAB_ALERT=true
  fi
  
  if (( $(echo "$AAB_INCREASE > $THRESHOLD_ABSOLUTE_MB" | bc -l) )); then
    echo -e "${RED}⚠️  ALERT: AAB size increased by ${AAB_INCREASE} MB (threshold: ${THRESHOLD_ABSOLUTE_MB} MB)${NC}"
    AAB_ALERT=true
  fi
  
  if [ "$AAB_ALERT" = "false" ]; then
    echo -e "${GREEN}✅ AAB size within acceptable limits${NC}"
  fi
fi

# Output sizes for GitHub Actions (if running in CI)
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  if [ "$APK_EXISTS" = "true" ]; then
    echo "apk_size_mb=$APK_SIZE_MB" >> $GITHUB_OUTPUT
    echo "apk_size_bytes=$APK_SIZE_BYTES" >> $GITHUB_OUTPUT
  fi

  if [ "$AAB_EXISTS" = "true" ]; then
    echo "aab_size_mb=$AAB_SIZE_MB" >> $GITHUB_OUTPUT
    echo "aab_size_bytes=$AAB_SIZE_BYTES" >> $GITHUB_OUTPUT
  fi
fi

# Exit with error if alerts triggered
if [ "${APK_ALERT:-false}" = "true" ] || [ "${AAB_ALERT:-false}" = "true" ]; then
  echo ""
  echo -e "${RED}❌ App size monitoring failed. Size increase exceeds thresholds.${NC}"
  echo "Recommendations:"
  echo "  - Review recent dependency additions"
  echo "  - Check for large assets or images"
  echo "  - Analyze bundle composition (run bundle analysis)"
  echo "  - Consider code splitting or lazy loading"
  exit 1
fi

echo ""
echo -e "${GREEN}✅ App size monitoring passed${NC}"

