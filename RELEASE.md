# FeaturePulse iOS SDK Release Guide

## Release Checklist

### Pre-Release

- [ ] All tests pass
- [ ] Code is reviewed and merged to main/supabase branch
- [ ] CHANGELOG.md is updated with new features/fixes
- [ ] VERSION file is updated
- [ ] README.md is up to date

### Creating a Release

#### 1. Update Version Files

```bash
# Update VERSION file
echo "1.1.0" > ios-sdk/VERSION

# Update CHANGELOG.md with new version section
# Add date and features/fixes
```

#### 2. Commit Version Changes

```bash
git add ios-sdk/VERSION ios-sdk/CHANGELOG.md
git commit -m "Release: iOS SDK v1.1.0"
```

#### 3. Create Git Tag

```bash
# Format: ios-sdk-vX.Y.Z
git tag -a ios-sdk-v1.1.0 -m "iOS SDK v1.1.0

Features:
- Feature 1
- Feature 2

Fixes:
- Fix 1
- Fix 2
"
```

#### 4. Push to GitHub

```bash
git push origin supabase
git push origin ios-sdk-v1.1.0
```

#### 5. Create GitHub Release

1. Go to: https://github.com/featurepulse/feature-pulse-ios/releases/new
2. Select tag: `ios-sdk-v1.1.0`
3. Release title: `iOS SDK v1.1.0`
4. Copy content from CHANGELOG.md for that version
5. Attach any binaries if needed
6. Click "Publish release"

### Post-Release

- [ ] Update integration documentation if API changed
- [ ] Announce release (Twitter, blog, etc.)
- [ ] Update example projects if needed
- [ ] Monitor issues for bug reports

## Versioning

We follow [Semantic Versioning](https://semver.org/):

**MAJOR.MINOR.PATCH** (e.g., 1.2.3)

- **MAJOR**: Breaking changes (incompatible API changes)
- **MINOR**: New features (backwards-compatible)
- **PATCH**: Bug fixes (backwards-compatible)

### Examples

- `1.0.0` → `2.0.0`: Breaking change (e.g., renamed public API)
- `1.0.0` → `1.1.0`: New feature (e.g., added dark mode support)
- `1.0.0` → `1.0.1`: Bug fix (e.g., fixed crash on iOS 17)

## Swift Package Manager

Users install the SDK via SPM:

```swift
dependencies: [
    .package(url: "https://github.com/featurepulse/feature-pulse-ios.git", from: "1.0.0")
]
```

SPM uses git tags to determine available versions.

### Version Resolution

- `from: "1.0.0"` → Any version >= 1.0.0 and < 2.0.0
- `upToNextMajor: "1.0.0"` → Same as above
- `upToNextMinor: "1.0.0"` → Any version >= 1.0.0 and < 1.1.0
- `exact: "1.0.0"` → Only version 1.0.0

## Release Types

### Major Release (Breaking Changes)

- API changes that break existing code
- Minimum iOS version bump
- Requires code changes from users
- Example: `1.9.0` → `2.0.0`

### Minor Release (New Features)

- New features that don't break existing code
- New public APIs
- Enhanced functionality
- Example: `1.0.0` → `1.1.0`

### Patch Release (Bug Fixes)

- Bug fixes
- Performance improvements
- Documentation updates
- Example: `1.0.0` → `1.0.1`

## Beta/Pre-Release Versions

For beta testing:

```bash
git tag -a ios-sdk-v1.1.0-beta.1 -m "iOS SDK v1.1.0 Beta 1"
```

Users can install beta versions:

```swift
.package(url: "https://github.com/featurepulse/feature-pulse-ios.git", exact: "1.1.0-beta.1")
```

## Rollback

If a release has critical issues:

1. **Delete the tag** (if not yet widely adopted):
   ```bash
   git tag -d ios-sdk-v1.1.0
   git push origin :refs/tags/ios-sdk-v1.1.0
   ```

2. **Create a hotfix release**:
   - Fix the issue
   - Release as `1.1.1` (patch)
   - Mark `1.1.0` as deprecated in GitHub releases

## Communication

### Release Notes Template

```markdown
# iOS SDK v1.1.0

## ✨ New Features

- Feature 1: Description
- Feature 2: Description

## 🐛 Bug Fixes

- Fix 1: Description
- Fix 2: Description

## 📝 Changes

- Change 1: Description

## ⚠️ Breaking Changes (if any)

- Breaking change: Migration guide

## 📦 Installation

\`\`\`swift
.package(url: "https://github.com/featurepulse/feature-pulse-ios.git", from: "1.1.0")
\`\`\`

## 🔗 Links

- [Full Changelog](https://github.com/featurepulse/feature-pulse-ios/blob/main/CHANGELOG.md)
- [Documentation](https://featurepul.se/docs)
```

## Current Version

**Latest**: v1.0.0 (2025-11-16)

