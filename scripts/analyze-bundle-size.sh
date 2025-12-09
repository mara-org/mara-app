#!/bin/bash
# Mara Bundle Size Analyzer
# Analyzes Flutter app bundle composition and identifies large components
# Frontend-only: analyzes APK/AAB structure, assets, and code

set -euo pipefail

# Configuration
APK_PATH="${1:-build/app/outputs/flutter-apk/app-release.apk}"
AAB_PATH="${2:-build/app/outputs/bundle/release/app-release.aab}"
OUTPUT_FILE="${3:-bundle-analysis-report.md}"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "🔍 Analyzing bundle composition..."

# Function to get file size in MB
get_size_mb() {
  local file="$1"
  if [ -f "$file" ]; then
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

# Function to format bytes
format_bytes() {
  local bytes="$1"
  if [ "$bytes" -gt 1048576 ]; then
    echo "scale=2; $bytes / 1024 / 1024" | bc | xargs printf "%.2f MB"
  elif [ "$bytes" -gt 1024 ]; then
    echo "scale=2; $bytes / 1024" | bc | xargs printf "%.2f KB"
  else
    echo "${bytes} B"
  fi
}

# Check if files exist
APK_EXISTS=false
AAB_EXISTS=false

if [ -f "$APK_PATH" ]; then
  APK_EXISTS=true
  APK_SIZE_MB=$(get_size_mb "$APK_PATH")
  echo -e "${GREEN}✅ APK found: ${APK_SIZE_MB} MB${NC}"
else
  echo -e "${YELLOW}⚠️  APK not found: $APK_PATH${NC}"
fi

if [ -f "$AAB_PATH" ]; then
  AAB_EXISTS=true
  AAB_SIZE_MB=$(get_size_mb "$AAB_PATH")
  echo -e "${GREEN}✅ AAB found: ${AAB_SIZE_MB} MB${NC}"
else
  echo -e "${YELLOW}⚠️  AAB not found: $AAB_PATH${NC}"
fi

if [ "$APK_EXISTS" = "false" ] && [ "$AAB_EXISTS" = "false" ]; then
  echo -e "${RED}❌ No build artifacts found. Cannot analyze bundle.${NC}"
  echo "Please build the app first: flutter build apk --release"
  exit 1
fi

# Create temporary directory for extraction
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo ""
echo "📦 Extracting and analyzing bundle contents..."

# Analyze APK if it exists
if [ "$APK_EXISTS" = "true" ]; then
  echo ""
  echo -e "${BLUE}=== APK Analysis ===${NC}"
  
  # Extract APK (it's a ZIP file)
  unzip -q "$APK_PATH" -d "$TEMP_DIR/apk" 2>/dev/null || {
    echo -e "${RED}❌ Failed to extract APK${NC}"
    exit 1
  }
  
  # Analyze lib/ directory (native libraries)
  if [ -d "$TEMP_DIR/apk/lib" ]; then
    echo ""
    echo "📚 Native Libraries:"
    find "$TEMP_DIR/apk/lib" -type f -exec ls -lh {} \; | awk '{print $5 "\t" $9}' | sort -hr | head -10 | while read size file; do
      echo "  $size - $(basename $file)"
    done
    
    LIB_TOTAL=$(find "$TEMP_DIR/apk/lib" -type f -exec stat -f%z {} \; 2>/dev/null | awk '{sum+=$1} END {print sum}' || find "$TEMP_DIR/apk/lib" -type f -exec stat -c%s {} \; 2>/dev/null | awk '{sum+=$1} END {print sum}' || echo "0")
    echo "  Total: $(format_bytes $LIB_TOTAL)"
  fi
  
  # Analyze assets/ directory
  if [ -d "$TEMP_DIR/apk/assets" ]; then
    echo ""
    echo "🖼️  Assets:"
    find "$TEMP_DIR/apk/assets" -type f -exec ls -lh {} \; | awk '{print $5 "\t" $9}' | sort -hr | head -10 | while read size file; do
      echo "  $size - $(basename $file)"
    done
    
    ASSETS_TOTAL=$(find "$TEMP_DIR/apk/assets" -type f -exec stat -f%z {} \; 2>/dev/null | awk '{sum+=$1} END {print sum}' || find "$TEMP_DIR/apk/assets" -type f -exec stat -c%s {} \; 2>/dev/null | awk '{sum+=$1} END {print sum}' || echo "0")
    echo "  Total: $(format_bytes $ASSETS_TOTAL)"
  fi
  
  # Analyze flutter_assets/ directory
  if [ -d "$TEMP_DIR/apk/assets/flutter_assets" ]; then
    echo ""
    echo "🎯 Flutter Assets:"
    find "$TEMP_DIR/apk/assets/flutter_assets" -type f -exec ls -lh {} \; | awk '{print $5 "\t" $9}' | sort -hr | head -15 | while read size file; do
      rel_path=${file#$TEMP_DIR/apk/assets/flutter_assets/}
      echo "  $size - $rel_path"
    done
    
    FLUTTER_ASSETS_TOTAL=$(find "$TEMP_DIR/apk/assets/flutter_assets" -type f -exec stat -f%z {} \; 2>/dev/null | awk '{sum+=$1} END {print sum}' || find "$TEMP_DIR/apk/assets/flutter_assets" -type f -exec stat -c%s {} \; 2>/dev/null | awk '{sum+=$1} END {print sum}' || echo "0")
    echo "  Total: $(format_bytes $FLUTTER_ASSETS_TOTAL)"
  fi
  
  # Analyze classes.dex (Dart code compiled to DEX)
  if [ -f "$TEMP_DIR/apk/classes.dex" ]; then
    DEX_SIZE=$(get_size_bytes "$TEMP_DIR/apk/classes.dex")
    echo ""
    echo "📝 Dart Code (classes.dex):"
    echo "  Size: $(format_bytes $DEX_SIZE)"
  fi
  
  # Check for multiple DEX files (multidex)
  DEX_COUNT=$(find "$TEMP_DIR/apk" -name "classes*.dex" | wc -l | tr -d ' ')
  if [ "$DEX_COUNT" -gt 1 ]; then
    echo ""
    echo "📚 Multiple DEX files detected (multidex):"
    find "$TEMP_DIR/apk" -name "classes*.dex" -exec ls -lh {} \; | awk '{print "  " $5 " - " $9}'
    MULTIDEX_TOTAL=$(find "$TEMP_DIR/apk" -name "classes*.dex" -exec stat -f%z {} \; 2>/dev/null | awk '{sum+=$1} END {print sum}' || find "$TEMP_DIR/apk" -name "classes*.dex" -exec stat -c%s {} \; 2>/dev/null | awk '{sum+=$1} END {print sum}' || echo "0")
    echo "  Total: $(format_bytes $MULTIDEX_TOTAL)"
  fi
  
  # Analyze resources (images, XML, etc.)
  if [ -d "$TEMP_DIR/apk/res" ]; then
    echo ""
    echo "🎨 Resources:"
    RES_TOTAL=$(find "$TEMP_DIR/apk/res" -type f -exec stat -f%z {} \; 2>/dev/null | awk '{sum+=$1} END {print sum}' || find "$TEMP_DIR/apk/res" -type f -exec stat -c%s {} \; 2>/dev/null | awk '{sum+=$1} END {print sum}' || echo "0")
    echo "  Total: $(format_bytes $RES_TOTAL)"
    
    # Find largest resource directories
    echo "  Largest resource directories:"
    find "$TEMP_DIR/apk/res" -type d -exec sh -c 'echo "$(find "$1" -type f -exec stat -f%z {} \; 2>/dev/null | awk "{sum+=\$1} END {print sum}" || find "$1" -type f -exec stat -c%s {} \; 2>/dev/null | awk "{sum+=\$1} END {print sum}" || echo "0") $1"' _ {} \; | sort -rn | head -5 | while read size dir; do
      rel_path=${dir#$TEMP_DIR/apk/res/}
      echo "    $(format_bytes $size) - $rel_path"
    done
  fi
fi

# Analyze AAB if it exists
if [ "$AAB_EXISTS" = "true" ]; then
  echo ""
  echo -e "${BLUE}=== AAB Analysis ===${NC}"
  
  # Extract AAB (it's a ZIP file)
  unzip -q "$AAB_PATH" -d "$TEMP_DIR/aab" 2>/dev/null || {
    echo -e "${RED}❌ Failed to extract AAB${NC}"
    exit 1
  }
  
  # AAB structure: base/ directory contains the main APK
  if [ -f "$TEMP_DIR/aab/base/dex/classes.dex" ] || [ -f "$TEMP_DIR/aab/base/root/classes.dex" ]; then
    DEX_FILES=$(find "$TEMP_DIR/aab/base" -name "classes*.dex" 2>/dev/null || true)
    if [ -n "$DEX_FILES" ]; then
      echo ""
      echo "📝 Dart Code (DEX files):"
      find "$TEMP_DIR/aab/base" -name "classes*.dex" -exec ls -lh {} \; | awk '{print "  " $5 " - " $9}'
      AAB_DEX_TOTAL=$(find "$TEMP_DIR/aab/base" -name "classes*.dex" -exec stat -f%z {} \; 2>/dev/null | awk '{sum+=$1} END {print sum}' || find "$TEMP_DIR/aab/base" -name "classes*.dex" -exec stat -c%s {} \; 2>/dev/null | awk '{sum+=$1} END {print sum}' || echo "0")
      echo "  Total: $(format_bytes $AAB_DEX_TOTAL)"
    fi
  fi
  
  # Analyze assets in AAB
  if [ -d "$TEMP_DIR/aab/base/assets" ]; then
    echo ""
    echo "🖼️  Assets:"
    find "$TEMP_DIR/aab/base/assets" -type f -exec ls -lh {} \; | awk '{print $5 "\t" $9}' | sort -hr | head -10 | while read size file; do
      echo "  $size - $(basename $file)"
    done
  fi
fi

# Analyze project assets
echo ""
echo -e "${BLUE}=== Project Assets Analysis ===${NC}"

if [ -d "assets" ]; then
  echo ""
  echo "📁 Assets Directory:"
  find assets -type f -exec ls -lh {} \; | awk '{print $5 "\t" $9}' | sort -hr | head -15 | while read size file; do
    echo "  $size - $file"
  done
  
  ASSETS_DIR_TOTAL=$(find assets -type f -exec stat -f%z {} \; 2>/dev/null | awk '{sum+=$1} END {print sum}' || find assets -type f -exec stat -c%s {} \; 2>/dev/null | awk '{sum+=$1} END {print sum}' || echo "0")
  echo "  Total: $(format_bytes $ASSETS_DIR_TOTAL)"
  
  # Find largest assets
  echo ""
  echo "🔍 Largest Assets (>100KB):"
  find assets -type f -exec sh -c 'size=$(stat -f%z "$1" 2>/dev/null || stat -c%s "$1" 2>/dev/null || echo "0"); if [ "$size" -gt 102400 ]; then echo "$size $1"; fi' _ {} \; | sort -rn | head -10 | while read size file; do
    echo "  $(format_bytes $size) - $file"
  done
fi

# Analyze pubspec dependencies
echo ""
echo -e "${BLUE}=== Dependency Analysis ===${NC}"

if [ -f "pubspec.yaml" ]; then
  echo ""
  echo "📦 Dependencies (from pubspec.yaml):"
  
  # Count dependencies
  DEP_COUNT=$(grep -E "^\s+[a-z_]+:" pubspec.yaml | grep -v "flutter:" | grep -v "sdk:" | wc -l | tr -d ' ')
  echo "  Total dependencies: $DEP_COUNT"
  
  # List large/common dependencies
  echo ""
  echo "  Key dependencies:"
  grep -E "^\s+(firebase|sentry|flutter_riverpod|go_router|dio|health|fl_chart)" pubspec.yaml | head -10 | sed 's/^/    /'
fi

# Generate recommendations
echo ""
echo -e "${BLUE}=== Recommendations ===${NC}"

RECOMMENDATIONS=()

# Check for large assets
if [ -d "assets" ]; then
  LARGE_ASSETS=$(find assets -type f -exec sh -c 'size=$(stat -f%z "$1" 2>/dev/null || stat -c%s "$1" 2>/dev/null || echo "0"); if [ "$size" -gt 1048576 ]; then echo "$1"; fi' _ {} \; | wc -l | tr -d ' ')
  if [ "$LARGE_ASSETS" -gt 0 ]; then
    RECOMMENDATIONS+=("⚠️  Found $LARGE_ASSETS large asset(s) (>1MB). Consider optimizing images or using WebP format.")
  fi
fi

# Check for multidex
if [ "${DEX_COUNT:-0}" -gt 1 ]; then
  RECOMMENDATIONS+=("⚠️  Multiple DEX files detected. Consider code splitting or removing unused dependencies.")
fi

# Check APK size
if [ "$APK_EXISTS" = "true" ]; then
  APK_SIZE_BYTES=$(get_size_bytes "$APK_PATH")
  if (( $(echo "$APK_SIZE_MB > 50" | bc -l) )); then
    RECOMMENDATIONS+=("⚠️  APK size is ${APK_SIZE_MB} MB (>50MB). Consider using Android App Bundle (AAB) for smaller downloads.")
  fi
fi

# Generate report
if [ ${#RECOMMENDATIONS[@]} -eq 0 ]; then
  RECOMMENDATIONS+=("✅ Bundle size looks good! No major optimizations needed.")
fi

echo ""
for rec in "${RECOMMENDATIONS[@]}"; do
  echo "  $rec"
done

# Generate markdown report
cat > "$OUTPUT_FILE" << EOF
# Bundle Size Analysis Report

**Generated:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")

## Summary

EOF

if [ "$APK_EXISTS" = "true" ]; then
  cat >> "$OUTPUT_FILE" << EOF
- **APK Size:** ${APK_SIZE_MB} MB
EOF
fi

if [ "$AAB_EXISTS" = "true" ]; then
  cat >> "$OUTPUT_FILE" << EOF
- **AAB Size:** ${AAB_SIZE_MB} MB
EOF
fi

cat >> "$OUTPUT_FILE" << EOF

## Recommendations

EOF

for rec in "${RECOMMENDATIONS[@]}"; do
  echo "- ${rec}" >> "$OUTPUT_FILE"
done

cat >> "$OUTPUT_FILE" << EOF

## Detailed Analysis

See console output above for detailed breakdown of:
- Native libraries
- Assets and images
- Dart code (DEX files)
- Resources
- Dependencies

## Next Steps

1. Review large assets and optimize if needed
2. Consider code splitting for large features
3. Remove unused dependencies
4. Use Android App Bundle (AAB) for Play Store to reduce download size
5. Enable ProGuard/R8 code shrinking if not already enabled

EOF

echo ""
echo -e "${GREEN}✅ Bundle analysis complete!${NC}"
echo "📄 Report saved to: $OUTPUT_FILE"

