#!/bin/bash
# Google-Level Flaky Test Tracking
# Tracks test flakiness across runs and quarantines flaky tests
# Based on Google's flaky test detection system

set -euo pipefail

# Configuration
FLAKY_THRESHOLD=3  # Quarantine after 3 failures
HISTORY_FILE=".github/test-flakiness-history.json"
QUARANTINE_FILE="test/quarantine/flaky_tests.txt"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "🔍 Tracking flaky tests..."

# Initialize history file if it doesn't exist
if [ ! -f "$HISTORY_FILE" ]; then
  mkdir -p "$(dirname "$HISTORY_FILE")"
  echo '{}' > "$HISTORY_FILE"
fi

# Initialize quarantine file if it doesn't exist
mkdir -p "$(dirname "$QUARANTINE_FILE")"
touch "$QUARANTINE_FILE"

# Function to update test history
update_test_history() {
  local test_name="$1"
  local status="$2"  # "passed" or "failed"
  local run_id="${GITHUB_RUN_ID:-$(date +%s)}"
  
  # Read current history
  local history=$(cat "$HISTORY_FILE")
  
  # Update history using jq if available, otherwise use basic JSON manipulation
  if command -v jq &> /dev/null; then
    # Add or update test entry
    history=$(echo "$history" | jq --arg test "$test_name" --arg status "$status" --arg run "$run_id" \
      '.[$test] = (.[$test] // {}) | .[$test].last_run = $run | .[$test].last_status = $status | 
       .[$test].failure_count = (if $status == "failed" then (.[$test].failure_count // 0) + 1 else (.[$test].failure_count // 0) end) |
       .[$test].total_runs = ((.[$test].total_runs // 0) + 1)')
    
    echo "$history" > "$HISTORY_FILE"
  else
    echo "⚠️  jq not available. Flaky test tracking limited."
  fi
}

# Function to check if test should be quarantined
should_quarantine() {
  local test_name="$1"
  
  if command -v jq &> /dev/null; then
    local failure_count=$(cat "$HISTORY_FILE" | jq -r ".[\"$test_name\"].failure_count // 0")
    
    if [ "$failure_count" -ge "$FLAKY_THRESHOLD" ]; then
      return 0  # Should quarantine
    fi
  fi
  
  return 1  # Don't quarantine
}

# Function to add test to quarantine
quarantine_test() {
  local test_name="$1"
  
  if ! grep -q "^$test_name$" "$QUARANTINE_FILE" 2>/dev/null; then
    echo "$test_name" >> "$QUARANTINE_FILE"
    echo -e "${YELLOW}⚠️  Quarantined flaky test: $test_name${NC}"
    
    # Create GitHub issue or comment
    if [ -n "${GITHUB_REPOSITORY:-}" ]; then
      echo "Would create GitHub issue for flaky test: $test_name"
    fi
  fi
}

# Function to parse test results
parse_test_results() {
  local test_output_file="${1:-}"
  
  if [ -z "$test_output_file" ] || [ ! -f "$test_output_file" ]; then
    echo "⚠️  No test output file provided"
    return
  fi
  
  # Extract failed tests from output
  # This is a simplified parser - adjust based on your test output format
  grep -E "FAILED|ERROR" "$test_output_file" | while read -r line; do
    # Extract test name (adjust regex based on your test output)
    test_name=$(echo "$line" | grep -oE "test/[^:]+\.dart:[0-9]+" | head -1 || echo "")
    
    if [ -n "$test_name" ]; then
      update_test_history "$test_name" "failed"
      
      if should_quarantine "$test_name"; then
        quarantine_test "$test_name"
      fi
    fi
  done
  
  # Extract passed tests
  grep -E "PASSED|PASS" "$test_output_file" | while read -r line; do
    test_name=$(echo "$line" | grep -oE "test/[^:]+\.dart:[0-9]+" | head -1 || echo "")
    
    if [ -n "$test_name" ]; then
      update_test_history "$test_name" "passed"
    fi
  done
}

# Function to generate flaky test report
generate_report() {
  echo ""
  echo "📊 Flaky Test Report"
  echo "==================="
  
  if command -v jq &> /dev/null; then
    local flaky_tests=$(cat "$HISTORY_FILE" | jq -r 'to_entries[] | select(.value.failure_count >= 2) | "\(.key): \(.value.failure_count) failures in \(.value.total_runs) runs"' || echo "")
    
    if [ -n "$flaky_tests" ]; then
      echo "$flaky_tests"
    else
      echo "✅ No flaky tests detected"
    fi
    
    # Show quarantined tests
    if [ -f "$QUARANTINE_FILE" ] && [ -s "$QUARANTINE_FILE" ]; then
      echo ""
      echo "🚫 Quarantined Tests:"
      cat "$QUARANTINE_FILE" | while read -r test; do
        echo "  - $test"
      done
    fi
  else
    echo "⚠️  jq not available. Install jq for detailed reports."
  fi
}

# Main execution
if [ "${1:-}" = "report" ]; then
  generate_report
elif [ "${1:-}" = "parse" ]; then
  parse_test_results "${2:-}"
else
  echo "Usage: $0 [report|parse <test_output_file>]"
  echo ""
  echo "  report              - Generate flaky test report"
  echo "  parse <file>        - Parse test results and update history"
  exit 1
fi

