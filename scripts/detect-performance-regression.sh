#!/bin/bash
# Google-Level Performance Regression Detection
# Detects performance regressions in CI by comparing benchmarks
# Based on Google's performance testing infrastructure

set -euo pipefail

# Configuration
PERFORMANCE_THRESHOLD_PERCENT=5  # Alert if performance degrades by 5%
BASELINE_FILE=".github/performance-baseline.json"
CURRENT_RESULTS_FILE="performance-results.json"
OUTPUT_FILE="performance-regression-report.md"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "⚡ Detecting performance regressions..."

# Function to get baseline metric
get_baseline_metric() {
  local metric_name="$1"
  
  if [ -f "$BASELINE_FILE" ] && command -v jq &> /dev/null; then
    jq -r ".[\"$metric_name\"] // empty" "$BASELINE_FILE" 2>/dev/null || echo ""
  else
    echo ""
  fi
}

# Function to compare metrics
compare_metrics() {
  local metric_name="$1"
  local current_value="$2"
  local baseline_value="$3"
  
  if [ -z "$baseline_value" ] || [ "$baseline_value" = "null" ] || [ "$baseline_value" = "" ]; then
    echo "⚠️  No baseline for $metric_name"
    return 2  # No baseline
  fi
  
  # Calculate percentage change
  local diff=$(echo "scale=2; $current_value - $baseline_value" | bc)
  local percent_change=$(echo "scale=2; ($diff / $baseline_value) * 100" | bc)
  
  # Check if regression detected
  if (( $(echo "$percent_change > $PERFORMANCE_THRESHOLD_PERCENT" | bc -l) )); then
    echo -e "${RED}❌ REGRESSION: $metric_name increased by ${percent_change}%${NC}"
    echo "  Baseline: $baseline_value"
    echo "  Current: $current_value"
    return 1  # Regression detected
  elif (( $(echo "$percent_change < -$PERFORMANCE_THRESHOLD_PERCENT" | bc -l) )); then
    echo -e "${GREEN}✅ IMPROVEMENT: $metric_name improved by ${percent_change}%${NC}"
    echo "  Baseline: $baseline_value"
    echo "  Current: $current_value"
    return 0  # Improvement
  else
    echo -e "${GREEN}✅ STABLE: $metric_name changed by ${percent_change}% (within threshold)${NC}"
    return 0  # Stable
  fi
}

# Function to extract performance metrics from Flutter test output
extract_metrics() {
  local test_output_file="${1:-}"
  local metrics_file="${2:-$CURRENT_RESULTS_FILE}"
  
  # Initialize metrics JSON
  local metrics='{}'
  
  if command -v jq &> /dev/null; then
    # Extract metrics from test output
    # This is a template - adjust based on your actual performance test output
    
    # Example: Extract app start time
    if [ -f "$test_output_file" ]; then
      local app_start_time=$(grep -oE "App start time: [0-9.]+ms" "$test_output_file" | grep -oE "[0-9.]+" | head -1 || echo "")
      if [ -n "$app_start_time" ]; then
        metrics=$(echo "$metrics" | jq --arg val "$app_start_time" '.app_start_time_ms = ($val | tonumber)')
      fi
      
      # Example: Extract frame render time
      local frame_time=$(grep -oE "Frame render time: [0-9.]+ms" "$test_output_file" | grep -oE "[0-9.]+" | head -1 || echo "")
      if [ -n "$frame_time" ]; then
        metrics=$(echo "$metrics" | jq --arg val "$frame_time" '.frame_render_time_ms = ($val | tonumber)')
      fi
      
      # Example: Extract memory usage
      local memory_mb=$(grep -oE "Memory usage: [0-9.]+MB" "$test_output_file" | grep -oE "[0-9.]+" | head -1 || echo "")
      if [ -n "$memory_mb" ]; then
        metrics=$(echo "$metrics" | jq --arg val "$memory_mb" '.memory_usage_mb = ($val | tonumber)')
      fi
    fi
    
    # Save metrics
    echo "$metrics" > "$metrics_file"
  else
    echo "⚠️  jq not available. Cannot extract metrics."
  fi
}

# Function to update baseline
update_baseline() {
  local metrics_file="${1:-$CURRENT_RESULTS_FILE}"
  
  if [ ! -f "$metrics_file" ]; then
    echo "⚠️  No metrics file to update baseline"
    return
  fi
  
  mkdir -p "$(dirname "$BASELINE_FILE")"
  cp "$metrics_file" "$BASELINE_FILE"
  echo "✅ Baseline updated"
}

# Function to generate regression report
generate_report() {
  local metrics_file="${1:-$CURRENT_RESULTS_FILE}"
  local has_regression=false
  
  echo ""
  echo "📊 Performance Regression Report"
  echo "================================"
  
  if [ ! -f "$metrics_file" ]; then
    echo "⚠️  No performance results found"
    return
  fi
  
  if ! command -v jq &> /dev/null; then
    echo "⚠️  jq not available. Install jq for detailed reports."
    return
  fi
  
  # Compare each metric
  jq -r 'to_entries[] | "\(.key)|\(.value)"' "$metrics_file" | while IFS='|' read -r key value; do
    baseline=$(get_baseline_metric "$key")
    
    if [ -n "$baseline" ]; then
      if ! compare_metrics "$key" "$value" "$baseline"; then
        has_regression=true
      fi
    else
      echo "ℹ️  New metric: $key = $value (no baseline)"
    fi
  done
  
  # Generate markdown report
  cat > "$OUTPUT_FILE" << EOF
# Performance Regression Report

**Generated:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")
**Commit:** ${GITHUB_SHA:-unknown}

## Metrics Comparison

| Metric | Baseline | Current | Change | Status |
|--------|----------|---------|--------|--------|
EOF

  jq -r 'to_entries[] | "\(.key)|\(.value)"' "$metrics_file" | while IFS='|' read -r key value; do
    baseline=$(get_baseline_metric "$key")
    
    if [ -n "$baseline" ]; then
      diff=$(echo "scale=2; $value - $baseline" | bc)
      percent=$(echo "scale=2; ($diff / $baseline) * 100" | bc)
      
      if (( $(echo "$percent > $PERFORMANCE_THRESHOLD_PERCENT" | bc -l) )); then
        status="❌ Regression"
      elif (( $(echo "$percent < -$PERFORMANCE_THRESHOLD_PERCENT" | bc -l) )); then
        status="✅ Improvement"
      else
        status="✅ Stable"
      fi
      
      echo "| $key | $baseline | $value | ${percent}% | $status |" >> "$OUTPUT_FILE"
    else
      echo "| $key | N/A | $value | New | ℹ️ New Metric |" >> "$OUTPUT_FILE"
    fi
  done
  
  cat >> "$OUTPUT_FILE" << EOF

## Recommendations

- Review recent code changes that might affect performance
- Check for new dependencies that might impact performance
- Consider optimizing identified bottlenecks
- Update baseline if regression is expected

EOF

  echo ""
  echo "📄 Report saved to: $OUTPUT_FILE"
}

# Main execution
case "${1:-}" in
  extract)
    extract_metrics "${2:-}" "${3:-$CURRENT_RESULTS_FILE}"
    ;;
  compare)
    generate_report "${2:-$CURRENT_RESULTS_FILE}"
    ;;
  update-baseline)
    update_baseline "${2:-$CURRENT_RESULTS_FILE}"
    ;;
  *)
    echo "Usage: $0 [extract|compare|update-baseline] [file]"
    echo ""
    echo "  extract <test_output> [metrics_file]  - Extract metrics from test output"
    echo "  compare [metrics_file]                 - Compare against baseline and generate report"
    echo "  update-baseline [metrics_file]         - Update baseline with current metrics"
    exit 1
    ;;
esac

