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

# Extract dependencies from pubspec.lock
# Use a simpler parsing approach
FIRST=true

# Parse pubspec.lock line by line
PACKAGE_NAME=""
VERSION=""
SOURCE="unknown"

while IFS= read -r line || [ -n "$line" ]; do
  # Match package name (format: "  package_name:")
  if [[ $line =~ ^[[:space:]]+([a-zA-Z0-9_-]+):[[:space:]]*$ ]]; then
    # Save previous package if we have one
    if [ -n "$PACKAGE_NAME" ] && [ -n "$VERSION" ]; then
      if [ "$FIRST" = true ]; then
        FIRST=false
      else
        echo "," >> "$OUTPUT_FILE"
      fi
      {
        echo "    {"
        echo "      \"name\": \"$PACKAGE_NAME\","
        echo "      \"version\": \"$VERSION\","
        echo "      \"source\": \"$SOURCE\""
        echo -n "    }"
      } >> "$OUTPUT_FILE"
    fi
    
    # Start new package
    PACKAGE_NAME="${BASH_REMATCH[1]}"
    VERSION=""
    SOURCE="unknown"
    
    # Skip metadata sections
    if [[ "$PACKAGE_NAME" == "packages" ]] || [[ "$PACKAGE_NAME" == "sdks" ]] || [[ "$PACKAGE_NAME" == "dependency_graph" ]]; then
      PACKAGE_NAME=""
      continue
    fi
  fi
  
  # Extract version
  if [ -n "$PACKAGE_NAME" ] && [[ $line =~ version:[[:space:]]*(.+) ]]; then
    VERSION="${BASH_REMATCH[1]}"
    VERSION=$(echo "$VERSION" | tr -d ' ')
  fi
  
  # Extract source
  if [ -n "$PACKAGE_NAME" ] && [[ $line =~ source:[[:space:]]*(.+) ]]; then
    SOURCE="${BASH_REMATCH[1]}"
    SOURCE=$(echo "$SOURCE" | tr -d ' ')
  fi
done < pubspec.lock

# Add last package if exists
if [ -n "$PACKAGE_NAME" ] && [ -n "$VERSION" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    echo "," >> "$OUTPUT_FILE"
  fi
  {
    echo "    {"
    echo "      \"name\": \"$PACKAGE_NAME\","
    echo "      \"version\": \"$VERSION\","
    echo "      \"source\": \"$SOURCE\""
    echo -n "    }"
  } >> "$OUTPUT_FILE"
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
