# FeaturePulse iOS SDK - Development Guide

## 🧹 Code Quality

### Code Formatting

**Indentation:**
- Use **4 spaces** for indentation (not tabs)
- Compatible with SwiftLint default settings
- VSCode settings are configured in `.vscode/settings.json`
- Format on save is enabled by default

**Line Length:**
- Maximum **120 characters** per line
- Editor ruler is set at 120 characters

### SwiftLint (REQUIRED)
**ALWAYS run before committing:**
```bash
cd ios-sdk
swiftlint --fix
```

Then verify no violations remain:
```bash
swiftlint
```

### Pre-Commit Checklist
- [ ] Run `swiftlint --fix`
- [ ] Fix any remaining SwiftLint warnings manually
- [ ] Ensure code compiles on all platforms (iOS, macOS, visionOS)
- [ ] Test changes in a sample app
- [ ] Update CHANGELOG.md if needed

## 📱 Platform Support

The SDK supports multiple Apple platforms:
- **iOS 17.0+** (includes iPadOS)
- **macOS 14.0+**
- **visionOS 1.0+**

### Platform-Specific Code

Use compiler directives for platform-specific APIs:

```swift
#if os(iOS)
.textContentType(.emailAddress)
.keyboardType(.emailAddress)
.autocapitalization(.none)
#endif
```

Common iOS-only APIs:
- `.navigationBarTitleDisplayMode()`
- `.keyboardType()`
- `.textContentType()`
- `.autocapitalization()`

## 📝 Naming Conventions

### Variables & Functions
- Use descriptive names (minimum 3 characters)
- Exceptions: `ok`, `id` (allowed in `.swiftlint.yml`)
- Use `camelCase` for variables and functions
- Use `PascalCase` for types

### Examples
```swift
// ✅ Good
let featureRequest = ...
let index = 0
let randomIndex = ...

// ❌ Bad
let i = 0
let j = 1
let x = ...
```

## 📏 Line Length

- **Maximum 120 characters per line**
- Split long lines for better readability

```swift
// ✅ Good
String(
    localized: "validation.title.too_short",
    defaultValue: "Title must be at least 3 characters",
    bundle: .module
)

// ❌ Bad
String(localized: "validation.title.too_short", defaultValue: "Title must be at least 3 characters", bundle: .module)
```

## 📦 Distribution Workflow

### Development Flow
1. **Make changes in private repo** (`/ios-sdk`)
2. **Test thoroughly** (compile on all platforms, run in sample app)
3. **Run SwiftLint** (`swiftlint --fix`)
4. **Commit changes** to private repo
5. **Wait for approval** to create new version
6. **Only then** copy to public repo and create release

### Important
- ❌ **DO NOT** push directly to public repo
- ✅ **DO** test all changes in private repo first
- ✅ **DO** run SwiftLint before every commit
- ✅ **DO** update VERSION and CHANGELOG.md for releases

## 🏗️ Build & Test

### Compile for all platforms
```bash
# iOS
swift build -c release --triple arm64-apple-ios17.0

# macOS
swift build -c release --triple arm64-apple-macos14.0

# Simulator
swift build -c release --triple arm64-apple-ios17.0-simulator
```

### Test in Xcode
1. Open a sample project
2. Add package dependency (local path)
3. Test on iOS, macOS, and visionOS simulators
4. Verify all features work correctly

## 🐛 Common Issues

### "SDK does not match" error
- This was fixed by switching to open source distribution
- SDK now compiles with any Xcode version

### Platform-specific API errors
- Always wrap iOS-only APIs in `#if os(iOS)`
- Test compilation on all platforms

### SwiftLint violations
- Run `swiftlint --fix` first
- Check `.swiftlint.yml` for custom rules
- Some identifiers are excluded (ok, id)

## 📚 Resources

- [SwiftLint Rules](https://realm.github.io/SwiftLint/rule-directory.html)
- [Swift Package Manager](https://swift.org/package-manager/)
- [Platform Availability](https://developer.apple.com/documentation/swift/checking-api-availability)

