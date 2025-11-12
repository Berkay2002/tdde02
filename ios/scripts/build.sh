#!/bin/bash
# iOS Build Script
# Run from project root: ./ios/scripts/build.sh

set -e

echo "🚀 Starting iOS build process..."

# Navigate to project root
cd "$(dirname "$0")/../.."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}📦 Step 1: Installing Flutter dependencies...${NC}"
flutter pub get

echo -e "${BLUE}🔨 Step 2: Generating Riverpod code...${NC}"
dart run build_runner build --delete-conflicting-outputs

echo -e "${BLUE}🧹 Step 3: Cleaning build cache...${NC}"
flutter clean

echo -e "${BLUE}📱 Step 4: Installing CocoaPods dependencies...${NC}"
cd ios
pod install --repo-update
cd ..

echo -e "${BLUE}🔍 Step 5: Analyzing code...${NC}"
flutter analyze

echo -e "${BLUE}🏗️  Step 6: Building iOS app...${NC}"
flutter build ios --no-codesign

echo -e "${GREEN}✅ iOS build completed successfully!${NC}"
echo -e "${GREEN}Build artifacts: build/ios/iphoneos/Runner.app${NC}"
