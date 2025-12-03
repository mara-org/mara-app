#!/bin/bash

# Install Git hooks for Mara Flutter app
# This script copies the pre-commit hook to .git/hooks/pre-commit and makes it executable

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOKS_DIR="$PROJECT_ROOT/.git/hooks"
PRE_COMMIT_SOURCE="$SCRIPT_DIR/hooks/pre-commit"
PRE_COMMIT_TARGET="$HOOKS_DIR/pre-commit"

echo "🔧 Installing Git hooks for Mara app..."

# Check if .git directory exists
if [ ! -d "$PROJECT_ROOT/.git" ]; then
    echo "❌ Error: .git directory not found. Are you in a Git repository?"
    exit 1
fi

# Create .git/hooks directory if it doesn't exist
mkdir -p "$HOOKS_DIR"

# Check if pre-commit hook source exists
if [ ! -f "$PRE_COMMIT_SOURCE" ]; then
    echo "❌ Error: Pre-commit hook source not found at $PRE_COMMIT_SOURCE"
    exit 1
fi

# Copy pre-commit hook
echo "📋 Copying pre-commit hook..."
cp "$PRE_COMMIT_SOURCE" "$PRE_COMMIT_TARGET"

# Make it executable
chmod +x "$PRE_COMMIT_TARGET"

echo "✅ Git hooks installed successfully!"
echo ""
echo "The pre-commit hook will now run automatically before each commit."
echo "It will:"
echo "  - Format code with 'dart format .'"
echo "  - Analyze code with 'flutter analyze'"
echo ""
echo "To bypass the hook (not recommended), use: git commit --no-verify"

