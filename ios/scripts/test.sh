#!/bin/bash
# iOS Test Script
# Run from project root: ./ios/scripts/test.sh

set -e

echo "🧪 Running iOS tests..."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

cd "$(dirname "$0")/../.."

echo -e "${BLUE}1️⃣  Running Flutter tests...${NC}"
flutter test

echo -e "${BLUE}2️⃣  Running iOS unit tests...${NC}"
cd ios
xcodebuild test \
  -workspace Runner.xcworkspace \
  -scheme Runner \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:RunnerTests

echo -e "${GREEN}✅ All tests passed!${NC}"
