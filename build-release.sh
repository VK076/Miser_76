#!/bin/bash

# FinTrack App - Shipping Script
# This script automates the build process for shipping

set -e

PROJECT_PATH="/Users/vaishnavkrishnanunni/flutter-dev/finance_app"
cd "$PROJECT_PATH"

echo "=========================================="
echo "FinTrack App - Shipping Builder"
echo "=========================================="
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Step 1: Clean and get dependencies
echo -e "${BLUE}[Step 1/5]${NC} Cleaning and fetching dependencies..."
flutter clean
flutter pub get
echo -e "${GREEN}✓ Dependencies updated${NC}\n"

# Step 2: Analyze code
echo -e "${BLUE}[Step 2/5]${NC} Analyzing code..."
flutter analyze
echo -e "${GREEN}✓ Code analysis complete${NC}\n"

# Step 3: Build iOS
echo -e "${BLUE}[Step 3/5]${NC} Building iOS release..."
flutter build ios --release
echo -e "${GREEN}✓ iOS build complete${NC}"
echo "   Location: build/ios/iphoneos/Runner.app\n"

# Step 4: Build Android
echo -e "${BLUE}[Step 4/5]${NC} Building Android release..."
flutter build appbundle --release
echo -e "${GREEN}✓ Android build complete${NC}"
echo "   Location: build/app/outputs/bundle/release/app-release.aab\n"

# Step 5: Summary
echo -e "${BLUE}[Step 5/5]${NC} Build Summary"
echo "=========================================="
echo -e "${GREEN}✓ All builds completed successfully!${NC}\n"

echo "Next Steps:"
echo "1. iOS: Upload build/ios/iphoneos/Runner.app to App Store Connect"
echo "2. Android: Upload build/app/outputs/bundle/release/app-release.aab to Google Play Console"
echo "3. Fill in app details and metadata"
echo "4. Submit for review"
echo ""
echo "For detailed instructions, see: SHIPPING_GUIDE.md"
echo "=========================================="
