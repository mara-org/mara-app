#!/bin/bash

# iOS Production Build Script for Mara App
# Usage: ./scripts/build-production.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if API_BASE_URL is set
if [ -z "$API_BASE_URL" ]; then
    echo -e "${RED}Error: API_BASE_URL environment variable is not set${NC}"
    echo "Usage: API_BASE_URL=https://api.mara.app ./scripts/build-production.sh"
    exit 1
fi

# Build flags
BUILD_FLAGS="--release --dart-define=API_BASE_URL=$API_BASE_URL"

# Optional flags (set via environment variables)
if [ "$ENABLE_CRASH_REPORTING" = "true" ]; then
    if [ -z "$SENTRY_DSN" ]; then
        echo -e "${YELLOW}Warning: ENABLE_CRASH_REPORTING=true but SENTRY_DSN is not set${NC}"
    else
        BUILD_FLAGS="$BUILD_FLAGS --dart-define=ENABLE_CRASH_REPORTING=true --dart-define=SENTRY_DSN=$SENTRY_DSN"
    fi
fi

if [ "$ENABLE_ANALYTICS" = "true" ]; then
    BUILD_FLAGS="$BUILD_FLAGS --dart-define=ENABLE_ANALYTICS=true"
fi

if [ -n "$FIREBASE_PROJECT_ID" ]; then
    BUILD_FLAGS="$BUILD_FLAGS --dart-define=FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID"
fi

echo -e "${GREEN}Building iOS app for production...${NC}"
echo "Build flags: $BUILD_FLAGS"

flutter build ios $BUILD_FLAGS

echo -e "${GREEN}iOS build complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Open ios/Runner.xcworkspace in Xcode"
echo "2. Product → Archive"
echo "3. Distribute App → App Store Connect"
