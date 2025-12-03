#!/bin/bash

# Format and lint script for Mara Flutter app
# Run this script before committing to ensure code quality

set -e  # Exit on error

echo "🔍 Running Dart formatter..."
dart format .

echo ""
echo "🔍 Running Flutter analyze..."
flutter analyze

echo ""
echo "✅ Formatting and linting completed successfully!"

