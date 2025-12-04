#!/bin/bash
# Setup script for Mara app development environment
# Frontend-only: sets up Flutter development environment

set -e

echo "🚀 Setting up Mara app development environment..."
echo ""

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
  echo "❌ Flutter is not installed"
  echo "Please install Flutter: https://flutter.dev/docs/get-started/install"
  exit 1
fi

FLUTTER_VERSION=$(flutter --version | head -n 1)
echo "✅ Flutter found: $FLUTTER_VERSION"

# Check Flutter version (should be 3.27.0)
REQUIRED_VERSION="3.27.0"
CURRENT_VERSION=$(flutter --version | grep -oP 'Flutter \K[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)

if [ "$CURRENT_VERSION" != "$REQUIRED_VERSION" ]; then
  echo "⚠️  Flutter version mismatch:"
  echo "   Current: $CURRENT_VERSION"
  echo "   Required: $REQUIRED_VERSION"
  echo "   Consider switching: flutter version $REQUIRED_VERSION"
fi

# Install dependencies
echo ""
echo "📦 Installing dependencies..."
flutter pub get

# Install pre-commit hooks
echo ""
echo "🔧 Installing pre-commit hooks..."
if [ -f "tool/install_hooks.sh" ]; then
  bash tool/install_hooks.sh
else
  echo "⚠️  Pre-commit hooks script not found"
fi

# Verify setup
echo ""
echo "🧪 Verifying setup..."

# Run format check
echo "  Checking code formatting..."
dart format --output=none --set-exit-if-changed . > /dev/null 2>&1 || {
  echo "  ⚠️  Code formatting issues detected. Run 'dart format .' to fix."
}

# Run analyze
echo "  Running static analysis..."
flutter analyze --no-fatal-infos --no-fatal-warnings > /dev/null 2>&1 || {
  echo "  ⚠️  Static analysis issues detected. Run 'flutter analyze' for details."
}

# Run tests
echo "  Running tests..."
flutter test > /dev/null 2>&1 || {
  echo "  ⚠️  Some tests failed. Run 'flutter test' for details."
}

echo ""
echo "✅ Development environment setup complete!"
echo ""
echo "Next steps:"
echo "  1. Read CONTRIBUTING.md for coding guidelines"
echo "  2. Read docs/ARCHITECTURE.md for architecture overview"
echo "  3. Run 'flutter run' to start the app"
echo "  4. Run 'flutter test' to run all tests"
echo ""

