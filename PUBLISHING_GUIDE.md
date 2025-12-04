# FeaturePulse iOS SDK - Publishing Guide

## 📋 Overview

This guide explains how to publish updates to the FeaturePulse iOS SDK. The SDK is distributed as a **binary XCFramework** via Swift Package Manager to protect source code.

## 🏗️ Repository Structure

### Private Repository (Development)
**Location:** `/Users/alexnsbmr/Developer/web/feature-pulse/ios-sdk/`

Contains:
- ✅ `Sources/` - SDK source code (PRIVATE)
- ✅ `Scripts/` - Build and publish automation scripts
- ✅ `Package.swift` - Swift Package Manager manifest
- ✅ `README.md` - Public-facing documentation
- ✅ Internal documentation files

**Purpose:** Development, testing, and automation scripts

### Public Repository (Distribution)
**URL:** https://github.com/featurepulse/feature-pulse-ios

Contains:
- ✅ `Sources/FeaturePulse.xcframework/` - Binary XCFramework (compiled code 🔒)
- ✅ `Sources/FeaturePulseWrapper/` - Wrapper target (links binary + dependencies)
- ✅ `Package.swift` - Path-based binary target + wrapper
- ✅ `README.md` - Public documentation
- ✅ `LICENSE` - MIT License
- ❌ NO actual source code - Only compiled binary
- ❌ NO Scripts/ folder
- ❌ NO internal documentation

**Purpose:** Public distribution for SDK users (source code protected 🔒)

## 🚀 Publishing a New Version

### Step 1: Update Version Files

```bash
cd /Users/alexnsbmr/Developer/web/feature-pulse/ios-sdk

# Update VERSION file
echo "X.Y.Z" > VERSION

# Update CHANGELOG.md with new version section
# Add features, fixes, improvements
```

### Step 2: Build the Binary XCFramework

```bash
# Build binary
VERSION=X.Y.Z ./Scripts/build-xcframework-with-resources.sh

# ✅ Note the checksum displayed at the end!
```

**Output:**
- Binary: `xcframework-with-resources/FeaturePulse.xcframework`
- Archive: `xcframework-with-resources/FeaturePulse-X.Y.Z.xcframework.zip`
- Checksum: Displayed in terminal output

### Step 3: Update Public Repository

```bash
cd /Users/alexnsbmr/Developer/ios/feature-pulse-ios

# Remove old XCFramework
rm -rf Sources/FeaturePulse.xcframework

# Copy new XCFramework
cp -r /Users/alexnsbmr/Developer/web/feature-pulse/ios-sdk/xcframework-with-resources/FeaturePulse.xcframework Sources/

# Copy README
cp /Users/alexnsbmr/Developer/web/feature-pulse/ios-sdk/README.md .

# Verify structure
ls -la Sources/
# Should see: FeaturePulse.xcframework/ and FeaturePulseWrapper/
```

### Step 4: Commit and Tag (ONE commit per version)

```bash
# Stage changes
git add -A

# Create commit (one commit per version for clean history)
git commit -m "Release X.Y.Z

✨ New Features:
- Feature 1: Description
- Feature 2: Description

🐛 Bug Fixes:
- Fix 1: Description
- Fix 2: Description

🌍 Localization:
- Added/updated translations

🎨 UI/UX Improvements:
- Improvement 1: Description

📦 Technical:
- Technical change 1
- Technical change 2"

# Tag the release
git tag -a X.Y.Z -m "Release X.Y.Z"

# Push to GitHub (regular push, NOT force)
git push origin main
git push origin X.Y.Z
```

**Result:** Linear commit history showing all releases:
```
6dfa3d9 Initial release: FeaturePulse iOS SDK v1.0.0
abc1234 Release 1.0.1
def5678 Release 1.0.2
...
```

### Step 5: Verify the Release

1. **Check GitHub repository:**
   - Go to: https://github.com/featurepulse/feature-pulse-ios/commits/main
   - Verify one commit per version (linear history)
   - Verify new commit on top of previous versions
   - Verify NO Scripts/ folder visible
   - Verify Sources/ contains XCFramework and wrapper

2. **Test installation:**
   ```bash
   # In a test project, verify the SDK can be added
   # File > Add Package Dependencies
   # URL: https://github.com/featurepulse/feature-pulse-ios
   ```

## 📦 Version Numbering

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (X.0.0): Breaking changes
- **MINOR** (0.X.0): New features, backwards-compatible
- **PATCH** (0.0.X): Bug fixes, backwards-compatible

## 🔒 Security Best Practices

### Never Commit to Public Repo:
- ❌ API keys or secrets
- ❌ Internal build scripts (`Scripts/` folder)
- ❌ Source code (`Sources/` with actual Swift files) - Use binary distribution
- ❌ Development documentation
- ❌ Test projects with real credentials
- ❌ `.env` files or configuration files

### Always Use Placeholders in README:
- ✅ `"your-api-key-here"` in examples
- ✅ Generic email addresses in documentation
- ✅ Example project names, not real ones

### Binary Distribution Advantages:
- ✅ Source code is completely protected
- ✅ Compiled binary cannot be decompiled to original code
- ✅ Only expose public API interfaces
- ✅ Maintain full control over implementation details

## 📱 User Installation

After publishing, users can install your SDK:

```swift
// In Xcode: File > Add Package Dependencies
// URL: https://github.com/featurepulse/feature-pulse-ios

// Or in Package.swift:
dependencies: [
    .package(url: "https://github.com/featurepulse/feature-pulse-ios", from: "X.Y.Z")
]
```

## 🆘 Troubleshooting

### "Permission denied" when pushing
- Make sure you have write access to the `featurepulse` organization
- Check that you're authenticated with GitHub (`gh auth status`)

### "No such module 'StableID'" error
- The wrapper target should handle this automatically
- Verify `Sources/FeaturePulseWrapper/FeaturePulseWrapper.swift` exists
- Verify `Package.swift` has wrapper target with StableID dependency

### "Old version still showing"
- Make sure you pushed the tag: `git push origin X.Y.Z`
- Tags must be pushed separately from commits
- SPM caches may take a few minutes to update
- Users may need to: File → Packages → Update to Latest Package Versions

## 📋 Current State

- **Public repo:** https://github.com/featurepulse/feature-pulse-ios
- **Distribution:** Binary XCFramework (source code protected 🔒)
- **Current version:** 1.0.0
- **Commits:** One commit per version (linear history ✅)
- **Structure:**
  ```
  feature-pulse-ios/
  ├── Sources/
  │   ├── FeaturePulse.xcframework/      ← Binary
  │   └── FeaturePulseWrapper/           ← Wrapper
  │       └── FeaturePulseWrapper.swift  ← Links binary + StableID
  ├── Package.swift                      ← Path-based binary target
  ├── README.md
  ├── LICENSE
  └── .gitignore
  ```

## 🎯 Best Practices

1. **Always test in private repo first**
2. **Review public files before pushing**
3. **Use descriptive commit messages**
4. **Tag every release**
5. **Keep changelog in CHANGELOG.md**
6. **Never commit secrets**
7. **One commit per version for clean history**

---

**Public Repository:** https://github.com/featurepulse/feature-pulse-ios  
**Private Development:** `/Users/alexnsbmr/Developer/web/feature-pulse/ios-sdk/`

Made with ❤️ for FeaturePulse
