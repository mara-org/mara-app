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

# Start building JSON SBOM
cat > "$OUTPUT_FILE" <<EOF
{
  "sbomVersion": "1.0",
  "format": "mara-sbom-v1",
  "name": "$APP_NAME",
  "version": "$APP_VERSION",
  "timestamp": "$TIMESTAMP",
  "tool": "generate_sbom.sh",
  "note": "This is a simplified SBOM. For production use, consider using CycloneDX or SPDX format.",
  "dependencies": [
EOF

# Extract dependencies from pubspec.lock
# Parse the lock file to get package names and versions
FIRST=true
while IFS= read -r line; do
  # Match package entries in pubspec.lock
  if [[ $line =~ ^[[:space:]]*([a-zA-Z0-9_-]+):[[:space:]]*$ ]]; then
    PACKAGE_NAME="${BASH_REMATCH[1]}"
    
    # Skip if it's a description or other metadata
    if [[ "$PACKAGE_NAME" == "packages" ]] || [[ "$PACKAGE_NAME" == "sdks" ]] || [[ "$PACKAGE_NAME" == "dependency_graph" ]]; then
      continue
    fi
    
    # Read next few lines to find version
    VERSION=""
    SOURCE=""
    while IFS= read -r next_line; do
      if [[ $next_line =~ version:[[:space:]]*(.+) ]]; then
        VERSION="${BASH_REMATCH[1]}"
        VERSION=$(echo "$VERSION" | tr -d ' ')
      elif [[ $next_line =~ source:[[:space:]]*(.+) ]]; then
        SOURCE="${BASH_REMATCH[1]}"
        SOURCE=$(echo "$SOURCE" | tr -d ' ')
      elif [[ $next_line =~ ^[[:space:]]*[a-zA-Z] ]] && [[ ! $next_line =~ ^[[:space:]]*(version|source|description): ]]; then
        break
      fi
    done
    
    # Only add if we found a version
    if [ -n "$VERSION" ]; then
      if [ "$FIRST" = true ]; then
        FIRST=false
      else
        echo "," >> "$OUTPUT_FILE"
      fi
      
      cat >> "$OUTPUT_FILE" <<DEPEOF
    {
      "name": "$PACKAGE_NAME",
      "version": "$VERSION",
      "source": "${SOURCE:-unknown}"
    }DEPEOF
    fi
  fi
done < pubspec.lock

# Close JSON
cat >> "$OUTPUT_FILE" <<EOF

  ]
}
EOF

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

