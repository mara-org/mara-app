#!/bin/bash
# Generate CHANGELOG.md from git commit history
# Uses conventional commits format if available, otherwise uses commit messages

set -e

CHANGELOG_FILE="CHANGELOG.md"
TEMP_CHANGELOG="/tmp/changelog_temp.md"

# Get the latest tag or use initial commit
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
if [ -z "$LATEST_TAG" ]; then
  # No tags found, use first commit
  LATEST_TAG=$(git rev-list --max-parents=0 HEAD 2>/dev/null || echo "HEAD")
fi

echo "📝 Generating changelog from $LATEST_TAG to HEAD..."

# Get commits since last tag
COMMITS=$(git log "$LATEST_TAG..HEAD" --pretty=format:"%h|%s|%an|%ad" --date=short 2>/dev/null || echo "")

if [ -z "$COMMITS" ]; then
  echo "ℹ️  No new commits since $LATEST_TAG"
  exit 0
fi

# Create new changelog entry
CURRENT_DATE=$(date +"%Y-%m-%d")
VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}' | head -n 1 || echo "Unreleased")

cat > "$TEMP_CHANGELOG" << EOF
## [$VERSION] - $CURRENT_DATE

### Added
EOF

# Categorize commits
ADDED_COUNT=0
CHANGED_COUNT=0
FIXED_COUNT=0
REMOVED_COUNT=0
OTHER_COUNT=0

while IFS='|' read -r hash subject author date; do
  # Categorize based on conventional commits or keywords
  SUBJECT_LOWER=$(echo "$subject" | tr '[:upper:]' '[:lower:]')
  
  if [[ "$SUBJECT_LOWER" =~ ^(feat|add|new) ]]; then
    echo "- $subject ($hash)" >> "$TEMP_CHANGELOG"
    ADDED_COUNT=$((ADDED_COUNT + 1))
  elif [[ "$SUBJECT_LOWER" =~ ^(fix|bugfix) ]]; then
    if [ "$FIXED_COUNT" -eq 0 ]; then
      echo "" >> "$TEMP_CHANGELOG"
      echo "### Fixed" >> "$TEMP_CHANGELOG"
    fi
    echo "- $subject ($hash)" >> "$TEMP_CHANGELOG"
    FIXED_COUNT=$((FIXED_COUNT + 1))
  elif [[ "$SUBJECT_LOWER" =~ ^(change|update|modify|refactor) ]]; then
    if [ "$CHANGED_COUNT" -eq 0 ]; then
      echo "" >> "$TEMP_CHANGELOG"
      echo "### Changed" >> "$TEMP_CHANGELOG"
    fi
    echo "- $subject ($hash)" >> "$TEMP_CHANGELOG"
    CHANGED_COUNT=$((CHANGED_COUNT + 1))
  elif [[ "$SUBJECT_LOWER" =~ ^(remove|delete|deprecate) ]]; then
    if [ "$REMOVED_COUNT" -eq 0 ]; then
      echo "" >> "$TEMP_CHANGELOG"
      echo "### Removed" >> "$TEMP_CHANGELOG"
    fi
    echo "- $subject ($hash)" >> "$TEMP_CHANGELOG"
    REMOVED_COUNT=$((REMOVED_COUNT + 1))
  else
    OTHER_COUNT=$((OTHER_COUNT + 1))
  fi
done <<< "$COMMITS"

# Add "Other" section if needed
if [ "$OTHER_COUNT" -gt 0 ]; then
  echo "" >> "$TEMP_CHANGELOG"
  echo "### Other" >> "$TEMP_CHANGELOG"
  while IFS='|' read -r hash subject author date; do
    SUBJECT_LOWER=$(echo "$subject" | tr '[:upper:]' '[:lower:]')
    if [[ ! "$SUBJECT_LOWER" =~ ^(feat|add|new|fix|bugfix|change|update|modify|refactor|remove|delete|deprecate) ]]; then
      echo "- $subject ($hash)" >> "$TEMP_CHANGELOG"
    fi
  done <<< "$COMMITS"
fi

# Prepend to existing CHANGELOG.md
if [ -f "$CHANGELOG_FILE" ]; then
  # Backup existing changelog
  cp "$CHANGELOG_FILE" "${CHANGELOG_FILE}.bak"
  
  # Prepend new entry
  cat "$TEMP_CHANGELOG" > "$CHANGELOG_FILE"
  echo "" >> "$CHANGELOG_FILE"
  cat "${CHANGELOG_FILE}.bak" >> "$CHANGELOG_FILE"
  rm "${CHANGELOG_FILE}.bak"
else
  # Create new changelog
  cat > "$CHANGELOG_FILE" << EOF
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

EOF
  cat "$TEMP_CHANGELOG" >> "$CHANGELOG_FILE"
fi

rm "$TEMP_CHANGELOG"

echo "✅ Changelog generated: $CHANGELOG_FILE"
echo "  Added: $ADDED_COUNT"
echo "  Changed: $CHANGED_COUNT"
echo "  Fixed: $FIXED_COUNT"
echo "  Removed: $REMOVED_COUNT"
echo "  Other: $OTHER_COUNT"

