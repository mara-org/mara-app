#!/bin/bash
# Check per-file coverage and fail if new/modified files fall below threshold
# Usage: scripts/check-coverage-per-file.sh [threshold_percent] [lcov_file]

set -e

THRESHOLD=${1:-60}  # Default 60% coverage threshold
LCOV_FILE=${2:-coverage/lcov.info}

if [ ! -f "$LCOV_FILE" ]; then
  echo "❌ Coverage file not found: $LCOV_FILE"
  echo "Run tests with coverage first: flutter test --coverage"
  exit 1
fi

echo "📊 Checking per-file coverage (threshold: ${THRESHOLD}%)..."

# Get list of changed files in this PR/commit
if [ -n "$GITHUB_BASE_REF" ] && [ -n "$GITHUB_HEAD_REF" ]; then
  # PR context
  CHANGED_FILES=$(git diff --name-only origin/$GITHUB_BASE_REF...HEAD | grep '\.dart$' || true)
elif [ -n "$GITHUB_SHA" ]; then
  # Push context - check files changed in last commit
  CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD | grep '\.dart$' || true)
else
  # Local context - check all files
  CHANGED_FILES=$(find lib -name "*.dart" -type f || true)
fi

if [ -z "$CHANGED_FILES" ]; then
  echo "ℹ️ No Dart files changed, skipping per-file coverage check"
  exit 0
fi

FAILED_FILES=()
TOTAL_CHECKED=0

# Parse lcov.info to get coverage per file
while IFS= read -r file; do
  # Skip test files
  if [[ "$file" == *"/test/"* ]] || [[ "$file" == *"test.dart" ]]; then
    continue
  fi
  
  # Convert file path to match lcov format (lib/...)
  LCOV_PATH="SF:$file"
  
  # Extract coverage for this file from lcov.info
  FILE_SECTION=$(awk "/^$LCOV_PATH$/,/^end_of_record$/" "$LCOV_FILE" 2>/dev/null || true)
  
  if [ -z "$FILE_SECTION" ]; then
    echo "⚠️  No coverage data for: $file (file may not be tested)"
    continue
  fi
  
  TOTAL_CHECKED=$((TOTAL_CHECKED + 1))
  
  # Count total lines and hit lines
  TOTAL_LINES=$(echo "$FILE_SECTION" | grep -c "^DA:" || echo "0")
  HIT_LINES=$(echo "$FILE_SECTION" | grep "^DA:" | grep -v ",0$" | wc -l || echo "0")
  
  if [ "$TOTAL_LINES" -eq 0 ]; then
    continue
  fi
  
  # Calculate coverage percentage
  COVERAGE_PERCENT=$((HIT_LINES * 100 / TOTAL_LINES))
  
  if [ "$COVERAGE_PERCENT" -lt "$THRESHOLD" ]; then
    FAILED_FILES+=("$file: ${COVERAGE_PERCENT}%")
    echo "❌ $file: ${COVERAGE_PERCENT}% (below ${THRESHOLD}% threshold)"
  else
    echo "✅ $file: ${COVERAGE_PERCENT}%"
  fi
done <<< "$CHANGED_FILES"

if [ ${#FAILED_FILES[@]} -gt 0 ]; then
  echo ""
  echo "❌ ${#FAILED_FILES[@]} file(s) below ${THRESHOLD}% coverage threshold:"
  for failed in "${FAILED_FILES[@]}"; do
    echo "  - $failed"
  done
  echo ""
  echo "Please add tests to improve coverage for these files."
  exit 1
fi

if [ "$TOTAL_CHECKED" -eq 0 ]; then
  echo "ℹ️  No files to check (all changed files are test files or have no coverage data)"
  exit 0
fi

echo "✅ All checked files meet the ${THRESHOLD}% coverage threshold"
exit 0

