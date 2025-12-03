#!/bin/bash
# Generate Software Bill of Materials (SBOM) for Mara Flutter app
# This script extracts dependency information from pubspec.yaml and pubspec.lock
# Outputs a simplified JSON SBOM format

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_FILE="${PROJECT_ROOT}/sbom.json"

echo "📦 Generating SBOM for Mara app..."

cd "$PROJECT_ROOT"

# Check if pubspec files exist
if [ ! -f "pubspec.yaml" ]; then
  echo "❌ Error: pubspec.yaml not found"
  exit 1
fi

if [ ! -f "pubspec.lock" ]; then
  echo "⚠️ Warning: pubspec.lock not found. Running 'flutter pub get'..."
  flutter pub get || {
    echo "❌ Error: Failed to generate pubspec.lock"
    exit 1
  }
fi

# Extract app metadata
APP_NAME=$(grep "^name:" pubspec.yaml | sed 's/^name: *//' | tr -d ' ')
APP_VERSION=$(grep "^version:" pubspec.yaml | sed 's/^version: *//' | tr -d ' ')

# Generate timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Start building JSON SBOM header
{
  echo "{"
  echo "  \"sbomVersion\": \"1.0\","
  echo "  \"format\": \"mara-sbom-v1\","
  echo "  \"name\": \"$APP_NAME\","
  echo "  \"version\": \"$APP_VERSION\","
  echo "  \"timestamp\": \"$TIMESTAMP\","
  echo "  \"tool\": \"generate_sbom.sh\","
  echo "  \"note\": \"This is a simplified SBOM. For production use, consider using CycloneDX or SPDX format.\","
  echo "  \"dependencies\": ["
} > "$OUTPUT_FILE"

# Extract dependencies from pubspec.lock using a Python-like approach
# Use awk to parse the lock file more reliably
FIRST=true

# Parse pubspec.lock - look for package entries
CURRENT_PACKAGE=""
CURRENT_VERSION=""
CURRENT_SOURCE="unknown"

while IFS= read -r line || [ -n "$line" ]; do
  # Match package name (format: "  package_name:")
  if [[ $line =~ ^[[:space:]]+([a-zA-Z0-9_-]+):[[:space:]]*$ ]]; then
    # Save previous package if we have one
    if [ -n "$CURRENT_PACKAGE" ] && [ -n "$CURRENT_VERSION" ]; then
      # Skip metadata sections
      if [[ "$CURRENT_PACKAGE" != "packages" ]] && [[ "$CURRENT_PACKAGE" != "sdks" ]] && [[ "$CURRENT_PACKAGE" != "dependency_graph" ]]; then
        if [ "$FIRST" = true ]; then
          FIRST=false
        else
          echo "," >> "$OUTPUT_FILE"
        fi
        # Escape JSON special characters in values
        ESCAPED_NAME=$(echo "$CURRENT_PACKAGE" | sed 's/"/\\"/g')
        ESCAPED_VERSION=$(echo "$CURRENT_VERSION" | sed 's/"/\\"/g')
        ESCAPED_SOURCE=$(echo "$CURRENT_SOURCE" | sed 's/"/\\"/g')
        {
          echo "    {"
          echo "      \"name\": \"$ESCAPED_NAME\","
          echo "      \"version\": \"$ESCAPED_VERSION\","
          echo "      \"source\": \"$ESCAPED_SOURCE\""
          echo -n "    }"
        } >> "$OUTPUT_FILE"
      fi
    fi
    
    # Start new package
    CURRENT_PACKAGE="${BASH_REMATCH[1]}"
    CURRENT_VERSION=""
    CURRENT_SOURCE="unknown"
  fi
  
  # Extract version (handle both quoted and unquoted)
  if [ -n "$CURRENT_PACKAGE" ] && [[ $line =~ version:[[:space:]]*(.+) ]]; then
    CURRENT_VERSION="${BASH_REMATCH[1]}"
    # Remove quotes if present and trim whitespace
    CURRENT_VERSION=$(echo "$CURRENT_VERSION" | sed 's/^"//;s/"$//' | tr -d ' ')
  fi
  
  # Extract source
  if [ -n "$CURRENT_PACKAGE" ] && [[ $line =~ source:[[:space:]]*(.+) ]]; then
    CURRENT_SOURCE="${BASH_REMATCH[1]}"
    # Remove quotes if present and trim whitespace
    CURRENT_SOURCE=$(echo "$CURRENT_SOURCE" | sed 's/^"//;s/"$//' | tr -d ' ')
  fi
done < pubspec.lock

# Add last package if exists
if [ -n "$CURRENT_PACKAGE" ] && [ -n "$CURRENT_VERSION" ]; then
  if [[ "$CURRENT_PACKAGE" != "packages" ]] && [[ "$CURRENT_PACKAGE" != "sdks" ]] && [[ "$CURRENT_PACKAGE" != "dependency_graph" ]]; then
    if [ "$FIRST" = true ]; then
      FIRST=false
    else
      echo "," >> "$OUTPUT_FILE"
    fi
    # Escape JSON special characters
    ESCAPED_NAME=$(echo "$CURRENT_PACKAGE" | sed 's/"/\\"/g')
    ESCAPED_VERSION=$(echo "$CURRENT_VERSION" | sed 's/"/\\"/g')
    ESCAPED_SOURCE=$(echo "$CURRENT_SOURCE" | sed 's/"/\\"/g')
    {
      echo "    {"
      echo "      \"name\": \"$ESCAPED_NAME\","
      echo "      \"version\": \"$ESCAPED_VERSION\","
      echo "      \"source\": \"$ESCAPED_SOURCE\""
      echo -n "    }"
    } >> "$OUTPUT_FILE"
  fi
fi

# Close JSON
{
  echo ""
  echo "  ]"
  echo "}"
} >> "$OUTPUT_FILE"

# Validate JSON (if jq is available)
if command -v jq &> /dev/null; then
  if jq empty "$OUTPUT_FILE" 2>/dev/null; then
    echo "✅ SBOM generated successfully: $OUTPUT_FILE"
    DEPENDENCY_COUNT=$(jq '.dependencies | length' "$OUTPUT_FILE")
    echo "📊 Found $DEPENDENCY_COUNT dependencies"
  else
    echo "⚠️ Warning: Generated SBOM may not be valid JSON"
    echo "💡 Install 'jq' for JSON validation: brew install jq (macOS) or apt-get install jq (Linux)"
    # Try to show the error
    jq . "$OUTPUT_FILE" 2>&1 | head -5 || true
  fi
else
  echo "✅ SBOM generated: $OUTPUT_FILE"
  echo "💡 Install 'jq' for JSON validation: brew install jq (macOS) or apt-get install jq (Linux)"
fi

echo "📄 SBOM location: $OUTPUT_FILE"
echo ""
echo "Note: This is a simplified SBOM format. For production use, consider:"
echo "  - CycloneDX format (cyclonedx-dart)"
echo "  - SPDX format (spdx-tools)"
echo "  - Backend SBOM will be generated in a separate repository"
