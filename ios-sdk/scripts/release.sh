#!/bin/bash

# FeaturePulse iOS SDK Release Script
# Usage: ./ios-sdk/scripts/release.sh <version>
# Example: ./ios-sdk/scripts/release.sh 1.0.10

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if version argument is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Version number required${NC}"
    echo "Usage: ./ios-sdk/scripts/release.sh <version>"
    echo "Example: ./ios-sdk/scripts/release.sh 1.0.10"
    exit 1
fi

VERSION=$1
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"
IOS_SDK_DIR="$REPO_ROOT/ios-sdk"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  FeaturePulse iOS SDK Release v${VERSION}${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if we're in the right directory
if [ ! -f "$IOS_SDK_DIR/VERSION" ]; then
    echo -e "${RED}Error: VERSION file not found. Are you in the repository root?${NC}"
    exit 1
fi

# Check if git working directory is clean
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}Warning: You have uncommitted changes.${NC}"
    echo -e "${YELLOW}Please commit or stash them before releasing.${NC}"
    exit 1
fi

# Step 1: Update VERSION file
echo -e "${GREEN}[1/7] Updating VERSION file...${NC}"
echo "$VERSION" > "$IOS_SDK_DIR/VERSION"
echo "      Updated VERSION to $VERSION"

# Step 2: Check if CHANGELOG has entry for this version
echo -e "${GREEN}[2/7] Checking CHANGELOG...${NC}"
if ! grep -q "## \[$VERSION\]" "$IOS_SDK_DIR/CHANGELOG.md"; then
    echo -e "${RED}Error: CHANGELOG.md doesn't have an entry for version $VERSION${NC}"
    echo -e "${YELLOW}Please update CHANGELOG.md first with release notes.${NC}"
    exit 1
fi
echo "      CHANGELOG has entry for $VERSION ✓"

# Step 3: Commit version changes
echo -e "${GREEN}[3/7] Committing version changes...${NC}"
git add "$IOS_SDK_DIR/VERSION" "$IOS_SDK_DIR/CHANGELOG.md"
git commit -m "Release iOS SDK v${VERSION}

🚀 Generated with release script
" || echo "      No changes to commit"

# Step 4: Push to main branch
echo -e "${GREEN}[4/7] Pushing to main branch...${NC}"
git push origin main
echo "      Pushed to origin/main ✓"

# Step 5: Check if ios-sdk-repo remote exists, if not add it
echo -e "${GREEN}[5/7] Setting up SDK repository remote...${NC}"
if ! git remote | grep -q "^ios-sdk-repo$"; then
    echo "      Adding ios-sdk-repo remote..."
    git remote add ios-sdk-repo https://github.com/featurepulse/feature-pulse-ios.git
fi
echo "      Remote configured ✓"

# Step 6: Push ios-sdk folder to SDK repo using subtree
echo -e "${GREEN}[6/7] Syncing to SDK repository...${NC}"
echo "      This may take a moment..."
git subtree push --prefix=ios-sdk ios-sdk-repo main
echo "      Synced ios-sdk folder to SDK repo ✓"

# Step 7: Create tag and GitHub release on SDK repo
echo -e "${GREEN}[7/7] Creating tag and GitHub release...${NC}"

# Extract release notes from CHANGELOG
RELEASE_NOTES=$(awk "/## \[$VERSION\]/{flag=1;next}/## \[/{flag=0}flag" "$IOS_SDK_DIR/CHANGELOG.md" | sed '/^$/d' | head -50)

# Create tag on SDK repo
cd ~/Developer/ios/feature-pulse-ios 2>/dev/null || {
    echo -e "${YELLOW}      SDK repo not found locally, cloning...${NC}"
    git clone https://github.com/featurepulse/feature-pulse-ios.git ~/Developer/ios/feature-pulse-ios
    cd ~/Developer/ios/feature-pulse-ios
}

git fetch origin
git checkout main
git pull origin main

# Create and push tag
git tag -a "$VERSION" -m "iOS SDK v${VERSION}"
git push origin "$VERSION"
echo "      Created and pushed tag $VERSION ✓"

# Create GitHub release
gh release create "$VERSION" \
    --title "v${VERSION}" \
    --notes "$RELEASE_NOTES" \
    --repo featurepulse/feature-pulse-ios

cd "$REPO_ROOT"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✅ Release v${VERSION} Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📦 Release URL:${NC}"
echo "   https://github.com/featurepulse/feature-pulse-ios/releases/tag/${VERSION}"
echo ""
echo -e "${BLUE}📱 Users can now update:${NC}"
echo "   .package(url: \"https://github.com/featurepulse/feature-pulse-ios.git\", from: \"${VERSION}\")"
echo ""
