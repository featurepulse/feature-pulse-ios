# Changelog

All notable changes to the FeaturePulse iOS SDK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2025-11-24

### 🎨 UI Improvements
- **Full-width text in feature rows** - Title and description now expand to use all available horizontal space
- Better text layout and readability in `FeatureRequestRow`

### 🧹 Code Quality
- **SwiftLint compliance** - Fixed all SwiftLint warnings in source code
- Renamed short variable names (`i`, `j` → `index`, `randomIndex`)
- Split long lines for better readability
- Added SwiftLint identifier exclusions for `ok` and `id`

### 📚 Developer Experience
- **VSCode settings** - Added `.vscode/settings.json` with consistent formatting rules
- **4-space indentation** - Compatible with SwiftLint defaults
- **Development guide** - Created `DEVELOPMENT.md` with comprehensive guidelines
- **Cursor rules** - Added `.cursorrules` for AI assistant guidance
- Format on save enabled by default
- 120 character line length ruler

### 🔧 Platform Support
- Focused on **iOS 17.0+ only** (includes iPadOS)
- Removed macOS and visionOS for now (can be re-added later)
- Platform-specific code preserved for future expansion

### 📱 Requirements
- iOS 17.0+ (iPadOS included)
- Xcode 15.0+
- Swift 5.9+

### 🔗 Links
- [GitHub Repository](https://github.com/featurepulse/feature-pulse-ios)
- [Release v1.0.2](https://github.com/featurepulse/feature-pulse-ios/releases/tag/1.0.2)

---

## [1.0.1] - 2025-11-23

### 🎯 Major Changes

#### 📦 Distribution Model Change
- **BREAKING**: Switched from binary XCFramework to **open source** distribution
- SDK is now distributed as Swift source code via SPM
- Better CI/CD compatibility (especially Xcode Cloud)
- No more SDK version mismatch issues
- Users can now view and understand the full source code

#### 🧹 Code Quality
- Removed all `print()` statements for cleaner console output
- SDK now fails silently or throws proper Swift errors
- Added SwiftLint configuration for code consistency

### ✨ Why This Matters

**Before (Binary):**
- ❌ SDK compiled for specific Xcode/iOS versions
- ❌ Xcode Cloud compatibility issues
- ❌ "SDK does not match" errors
- ❌ Source code hidden

**After (Open Source):**
- ✅ Compiles with any Xcode version
- ✅ Perfect Xcode Cloud compatibility
- ✅ No SDK mismatch errors
- ✅ Full source code visibility
- ✅ Community contributions possible

### 📱 Requirements
- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

### 🔗 Links
- [GitHub Repository](https://github.com/featurepulse/feature-pulse-ios)
- [Release v1.0.1](https://github.com/featurepulse/feature-pulse-ios/releases/tag/1.0.1)

---

## [1.0.0] - 2025-11-19

### 🎉 Initial Release

#### ✨ Features

- **SwiftUI-Only Architecture** - Pure SwiftUI implementation with no UIKit dependencies
- **Modern Swift 6.0** - Uses `@Observable`, async/await, and Swift Concurrency
- **Feature Request Management**
  - View all feature requests in a clean list
  - Submit new feature requests with title, description, and optional email
  - Vote on feature requests with visual feedback
  - Detail view for viewing full request information
  - Real-time vote count updates
  - Status badges (pending, approved, in progress, completed, rejected)
  
- **Customization**
  - **Primary Color** - Customize vote and submit button colors to match your brand
  - **Status Badge Visibility** - Dashboard-controlled option to show/hide status badges
  
- **User Management**
  - Stable device-based user identification
  - Custom user ID support
  - Email collection (optional, hidden by default)
  - User name tracking
  
- **Vote Weighting by Payment Tier** 💰
  - Free users: 0 weight
  - Paid users: Weighted by Monthly Recurring Revenue (MRR)
  - Support for weekly, monthly, yearly, and lifetime subscriptions
  - Automatic MRR calculation from any subscription type
  - Perfect for prioritizing paying customer feedback
  
- **Multi-Language Support** 🌍
  - **Type-Safe Localization** using String Catalogs (`.xcstrings`)
  - Built-in translations for 4 languages:
    - 🇬🇧 English
    - 🇪🇸 Spanish (Español)
    - 🇫🇷 French (Français)
    - 🇩🇪 German (Deutsch)
  - Automatic language selection based on device settings
  
- **Shimmer Loading Effect** - Elegant loading animation with smart placeholder count
- **Smart Keyboard Handling** ⌨️
  - `@FocusState` for seamless field navigation
  - Return key changes based on context: "Next" → "Send"
  - Press "Send" on last field to submit form directly
  - Automatic field progression (Title → Description → Email)
  
- **Privacy-Focused** 🔒
  - Email field hidden by default
  - Device ID-only tracking unless email explicitly enabled
  - Dashboard control for email field visibility
  
- **RevenueCat Integration Support** - Easy sync with subscription data for vote weighting

#### 🎨 UI/UX

- Beautiful native iOS design with system colors
- Automatic dark mode support
- Smooth animations and transitions
- Pull-to-refresh functionality
- Native iOS keyboard behavior
- Skeleton screens with redacted placeholders

#### 📦 Distribution

- Binary XCFramework (deprecated in 1.0.1)
- Path-based SPM distribution
- Includes StableID dependency
- Includes localized resources

#### 📱 Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

#### 🔗 Links

- [GitHub Repository](https://github.com/featurepulse/feature-pulse-ios)
- [Release v1.0.0](https://github.com/featurepulse/feature-pulse-ios/releases/tag/1.0.0)

