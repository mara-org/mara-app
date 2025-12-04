#!/bin/bash
# Environment and Configuration Validation Script
# Scans code/config for insecure patterns and misconfigurations
# Frontend-only: checks Flutter app code, not backend

set -e

echo "🔍 Running environment and configuration validation..."

ERRORS=0
WARNINGS=0

# Configuration
CHECK_PRINT_STATEMENTS=true
CHECK_HTTP_URLS=true
CHECK_DEBUG_FLAGS=true
CHECK_HARDCODED_SECRETS=true

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to report error
report_error() {
  echo -e "${RED}❌ ERROR:${NC} $1"
  ERRORS=$((ERRORS + 1))
}

# Function to report warning
report_warning() {
  echo -e "${YELLOW}⚠️  WARNING:${NC} $1"
  WARNINGS=$((WARNINGS + 1))
}

# Function to report success
report_success() {
  echo -e "${GREEN}✅${NC} $1"
}

# 1. Check for print statements in production-critical code
if [ "$CHECK_PRINT_STATEMENTS" = "true" ]; then
  echo ""
  echo "Checking for print statements..."
  
  # Find print statements in lib/ (excluding test files)
  PRINT_STATEMENTS=$(find lib/ -name "*.dart" -type f ! -path "*/test/*" -exec grep -l "print(" {} \; 2>/dev/null || true)
  
  if [ -n "$PRINT_STATEMENTS" ]; then
    while IFS= read -r file; do
      # Check if print is wrapped in kDebugMode check
      if ! grep -q "kDebugMode" "$file" 2>/dev/null; then
        report_warning "Found 'print(' in $file without kDebugMode check. Consider using Logger instead."
      else
        report_success "print() in $file is properly guarded with kDebugMode"
      fi
    done <<< "$PRINT_STATEMENTS"
  else
    report_success "No print statements found in lib/"
  fi
fi

# 2. Check for HTTP URLs (should be HTTPS)
if [ "$CHECK_HTTP_URLS" = "true" ]; then
  echo ""
  echo "Checking for HTTP URLs (should use HTTPS)..."
  
  HTTP_URLS=$(grep -r "http://" lib/ --include="*.dart" 2>/dev/null | grep -v "// " | grep -v "http://localhost" | grep -v "http://127.0.0.1" || true)
  
  if [ -n "$HTTP_URLS" ]; then
    while IFS= read -r line; do
      report_error "Found HTTP URL (should use HTTPS): $line"
    done <<< "$HTTP_URLS"
  else
    report_success "No HTTP URLs found (excluding localhost)"
  fi
fi

# 3. Check for debug flags that should not be enabled in release
if [ "$CHECK_DEBUG_FLAGS" = "true" ]; then
  echo ""
  echo "Checking for debug flags in release code..."
  
  # Check for hardcoded debug flags
  DEBUG_FLAGS=$(grep -r "debug.*=.*true" lib/ --include="*.dart" 2>/dev/null | grep -v "kDebugMode" | grep -v "//" || true)
  
  if [ -n "$DEBUG_FLAGS" ]; then
    while IFS= read -r line; do
      report_warning "Found potential debug flag: $line"
    done <<< "$DEBUG_FLAGS"
  else
    report_success "No hardcoded debug flags found"
  fi
fi

# 4. Check for hardcoded secrets (basic pattern matching)
if [ "$CHECK_HARDCODED_SECRETS" = "true" ]; then
  echo ""
  echo "Checking for potential hardcoded secrets..."
  
  # Patterns to check (basic, not exhaustive)
  SECRET_PATTERNS=(
    "api[_-]?key\s*=\s*['\"][^'\"]{20,}"
    "secret[_-]?key\s*=\s*['\"][^'\"]{20,}"
    "password\s*=\s*['\"][^'\"]{8,}"
    "token\s*=\s*['\"][^'\"]{20,}"
    "private[_-]?key\s*=\s*['\"][^'\"]{20,}"
  )
  
  SECRETS_FOUND=0
  for pattern in "${SECRET_PATTERNS[@]}"; do
    MATCHES=$(grep -r -i -E "$pattern" lib/ --include="*.dart" 2>/dev/null | grep -v "//" | grep -v "TODO" || true)
    if [ -n "$MATCHES" ]; then
      while IFS= read -r line; do
        report_error "Potential hardcoded secret found: $line"
        SECRETS_FOUND=$((SECRETS_FOUND + 1))
      done <<< "$MATCHES"
    fi
  done
  
  if [ "$SECRETS_FOUND" -eq 0 ]; then
    report_success "No obvious hardcoded secrets found"
  fi
fi

# 5. Check for proper error handling (no bare catches)
echo ""
echo "Checking for proper error handling..."

BARE_CATCHES=$(grep -r "catch\s*(" lib/ --include="*.dart" 2>/dev/null | grep -v "catch (e" | grep -v "catch (error" | grep -v "catch (exception" || true)

if [ -n "$BARE_CATCHES" ]; then
  while IFS= read -r line; do
    report_warning "Found bare catch statement (should specify exception type): $line"
  done <<< "$BARE_CATCHES"
else
  report_success "No bare catch statements found"
fi

# Summary
echo ""
echo "=========================================="
echo "Validation Summary"
echo "=========================================="
echo -e "Errors: ${RED}$ERRORS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"

if [ "$ERRORS" -gt 0 ]; then
  echo ""
  echo -e "${RED}❌ Validation failed with $ERRORS error(s)${NC}"
  exit 1
elif [ "$WARNINGS" -gt 0 ]; then
  echo ""
  echo -e "${YELLOW}⚠️  Validation passed with $WARNINGS warning(s)${NC}"
  exit 0
else
  echo ""
  echo -e "${GREEN}✅ Validation passed with no errors or warnings${NC}"
  exit 0
fi

