#!/bin/bash

# FeaturePulse iOS SDK Release Script
# This script automates the release process for the iOS SDK

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
MONOREPO_ROOT="/Users/alexnsbmr/Developer/web/feature-pulse"
IOS_SDK_DIR="$MONOREPO_ROOT/ios-sdk"
PUBLIC_SDK_DIR="/Users/alexnsbmr/Developer/ios/feature-pulse-ios"

# Check if VERSION argument is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Version number required${NC}"
    echo "Usage: ./release.sh <version> [release-notes]"
    echo "Example: ./release.sh 1.0.11 'Bug fixes and improvements'"
    exit 1
fi

VERSION=$1
RELEASE_NOTES=${2:-""}

echo -e "${BLUE}🚀 Starting iOS SDK Release Process for v$VERSION${NC}\n"

# Step 1: Verify we're in the monorepo
if [ ! -f "$IOS_SDK_DIR/VERSION" ]; then
    echo -e "${RED}Error: VERSION file not found at $IOS_SDK_DIR/VERSION${NC}"
    exit 1
fi

# Step 2: Update VERSION file
echo -e "${YELLOW}📝 Updating VERSION file...${NC}"
echo "$VERSION" > "$IOS_SDK_DIR/VERSION"
echo -e "${GREEN}✅ VERSION file updated to $VERSION${NC}\n"

# Step 3: Check if CHANGELOG.md was updated
echo -e "${YELLOW}⚠️  Please ensure CHANGELOG.md has been updated with v$VERSION release notes${NC}"
read -p "Press Enter to continue or Ctrl+C to cancel..."
echo ""

# Step 4: Commit to monorepo
echo -e "${YELLOW}📦 Committing to monorepo...${NC}"
cd "$MONOREPO_ROOT"
git add ios-sdk/VERSION ios-sdk/CHANGELOG.md ios-sdk/
if [ -n "$RELEASE_NOTES" ]; then
    git commit -m "Release iOS SDK v$VERSION - $RELEASE_NOTES"
else
    git commit -m "Release iOS SDK v$VERSION"
fi
git push origin main
echo -e "${GREEN}✅ Committed to monorepo${NC}\n"

# Step 5: Sync to public SDK repository
echo -e "${YELLOW}🔄 Syncing to public SDK repository...${NC}"
cd "$PUBLIC_SDK_DIR"

# Sync with --delete flag to remove old files
rsync -av --delete --exclude='.git' --exclude='node_modules' --exclude='.build' \
  "$IOS_SDK_DIR/" .

echo -e "${BLUE}Files changed:${NC}"
git diff --name-status

echo ""
read -p "Review changes above. Press Enter to continue or Ctrl+C to cancel..."
echo ""

# Step 6: Commit to public SDK repo
echo -e "${YELLOW}📦 Committing to public SDK repository...${NC}"
git add -A

if [ -n "$RELEASE_NOTES" ]; then
    git commit -m "Release v$VERSION - $RELEASE_NOTES

$RELEASE_NOTES

🤖 Generated with Claude Code"
else
    git commit -m "Release v$VERSION

🤖 Generated with Claude Code"
fi

git push origin main
echo -e "${GREEN}✅ Committed to public SDK repository${NC}\n"

# Step 7: Create and push tag
echo -e "${YELLOW}🏷️  Creating git tag...${NC}"

if [ -n "$RELEASE_NOTES" ]; then
    git tag -a "$VERSION" -m "iOS SDK v$VERSION

$RELEASE_NOTES"
else
    git tag -a "$VERSION" -m "iOS SDK v$VERSION"
fi

git push origin "$VERSION"
echo -e "${GREEN}✅ Tag $VERSION created and pushed${NC}\n"

# Step 8: Create GitHub release
echo -e "${YELLOW}🎉 Creating GitHub release...${NC}"

if [ -n "$RELEASE_NOTES" ]; then
    NOTES="$RELEASE_NOTES

## 📦 Installation

\`\`\`swift
.package(url: \"https://github.com/featurepulse/feature-pulse-ios.git\", from: \"$VERSION\")
\`\`\`

## 🔗 Links

- [Full Changelog](https://github.com/featurepulse/feature-pulse-ios/blob/main/CHANGELOG.md)
- [Documentation](https://featurepul.se)

🤖 Generated with [Claude Code](https://claude.com/claude-code)"
else
    NOTES="See [CHANGELOG.md](https://github.com/featurepulse/feature-pulse-ios/blob/main/CHANGELOG.md) for full details.

## 📦 Installation

\`\`\`swift
.package(url: \"https://github.com/featurepulse/feature-pulse-ios.git\", from: \"$VERSION\")
\`\`\`

## 🔗 Links

- [Full Changelog](https://github.com/featurepulse/feature-pulse-ios/blob/main/CHANGELOG.md)
- [Documentation](https://featurepul.se)

🤖 Generated with [Claude Code](https://claude.com/claude-code)"
fi

gh release create "$VERSION" \
  --title "v$VERSION" \
  --notes "$NOTES" \
  --repo featurepulse/feature-pulse-ios

RELEASE_URL="https://github.com/featurepulse/feature-pulse-ios/releases/tag/$VERSION"
echo -e "${GREEN}✅ GitHub release created${NC}\n"

# Step 9: Summary
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Release Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}Version:${NC} $VERSION"
echo -e "${BLUE}Release URL:${NC} $RELEASE_URL"
echo ""
echo -e "${YELLOW}📋 Post-Release Checklist:${NC}"
echo -e "  [ ] Verify release at $RELEASE_URL"
echo -e "  [ ] Test SPM installation: File > Add Package Dependencies..."
echo -e "  [ ] Update documentation site (if needed)"
echo ""
