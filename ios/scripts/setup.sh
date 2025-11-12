#!/bin/bash
# iOS Setup Script
# Run from project root: ./ios/scripts/setup.sh

set -e

echo "🔧 Setting up iOS development environment..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo -e "${RED}❌ Error: iOS development requires macOS${NC}"
  echo -e "${YELLOW}ℹ️  You can prepare configuration on Windows, but building requires a Mac${NC}"
  exit 1
fi

echo -e "${BLUE}1️⃣  Checking Xcode installation...${NC}"
if ! command -v xcodebuild &> /dev/null; then
  echo -e "${RED}❌ Xcode not found. Please install Xcode from the App Store.${NC}"
  exit 1
fi
echo -e "${GREEN}✅ Xcode found: $(xcodebuild -version | head -n 1)${NC}"

echo -e "${BLUE}2️⃣  Checking CocoaPods installation...${NC}"
if ! command -v pod &> /dev/null; then
  echo -e "${YELLOW}⚠️  CocoaPods not found. Installing...${NC}"
  sudo gem install cocoapods
fi
echo -e "${GREEN}✅ CocoaPods found: $(pod --version)${NC}"

echo -e "${BLUE}3️⃣  Checking Flutter installation...${NC}"
if ! command -v flutter &> /dev/null; then
  echo -e "${RED}❌ Flutter not found. Please install Flutter SDK.${NC}"
  exit 1
fi
echo -e "${GREEN}✅ Flutter found: $(flutter --version | head -n 1)${NC}"

echo -e "${BLUE}4️⃣  Checking GoogleService-Info.plist...${NC}"
if [ ! -f "ios/Runner/GoogleService-Info.plist" ]; then
  echo -e "${RED}❌ GoogleService-Info.plist not found!${NC}"
  echo -e "${YELLOW}ℹ️  Please download it from Firebase Console and place it in ios/Runner/${NC}"
  exit 1
fi
echo -e "${GREEN}✅ GoogleService-Info.plist found${NC}"

echo -e "${BLUE}5️⃣  Installing Flutter dependencies...${NC}"
flutter pub get

echo -e "${BLUE}6️⃣  Generating Riverpod code...${NC}"
dart run build_runner build --delete-conflicting-outputs

echo -e "${BLUE}7️⃣  Installing CocoaPods dependencies...${NC}"
cd ios
pod install --repo-update
cd ..

echo -e "${BLUE}8️⃣  Opening Xcode to add GoogleService-Info.plist...${NC}"
echo -e "${YELLOW}⚠️  IMPORTANT: You must add GoogleService-Info.plist via Xcode!${NC}"
echo -e "${YELLOW}   1. In Xcode, right-click 'Runner' folder${NC}"
echo -e "${YELLOW}   2. Select 'Add Files to Runner...'${NC}"
echo -e "${YELLOW}   3. Select GoogleService-Info.plist${NC}"
echo -e "${YELLOW}   4. Check: Copy items if needed, Create groups, Add to targets: Runner${NC}"
echo -e "${YELLOW}   5. Click 'Add'${NC}"
echo ""
read -p "Press Enter to open Xcode workspace..."
open ios/Runner.xcworkspace

echo -e "${GREEN}✅ iOS setup complete!${NC}"
echo -e "${GREEN}Next steps:${NC}"
echo -e "  1. Add GoogleService-Info.plist via Xcode (see instructions above)"
echo -e "  2. Configure signing: Select your team in Xcode"
echo -e "  3. Run: flutter run -d iPhone"
