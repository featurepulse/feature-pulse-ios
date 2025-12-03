# Changelog

All notable changes to the FeaturePulse iOS SDK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.6] - 2025-01-30

### ✨ New Features

- **Privacy Manifest** - Added `PrivacyInfo.xcprivacy` for App Store compliance
  - Declares all data collection types (User ID, Email, Name, Purchase History, Product Interaction)
  - Declares API usage (UserDefaults for session tracking)
  - No tracking declared (NSPrivacyTracking = false)
  - Automatically merged with your app's privacy manifest during App Store submission
  - Ensures compliance with Apple's privacy requirements

- **Configurable Foreground Colors** - Enhanced color customization
  - `foregroundColor` - Configurable foreground color for vote buttons, submit button, and CTA button
  - Defaults to white for optimal contrast with primary color backgrounds
  - Allows full customization of button text and icon colors

### 🔧 Improvements

- **Color Configuration** - Improved color property naming
  - Renamed `textColor` to `foregroundColor` for better SwiftUI terminology alignment
  - More accurate naming reflects that colors apply to all foreground elements, not just text

### 📚 Documentation

- Updated README with privacy manifest information
- Added comprehensive privacy and data collection documentation
- Updated color customization examples with new property names

### 🔗 Links

- [GitHub Repository](https://github.com/featurepulse/feature-pulse-ios)
- [Release v1.0.6](https://github.com/featurepulse/feature-pulse-ios/releases/tag/1.0.6)

---

## [1.0.5] - 2025-12-01

### 🐛 Bug Fixes

- **Session Tracking Modifier Fix** - Fixed `.featurePulseSessionTracking()` modifier to work correctly
  - Changed from non-existent `SceneModifier` to proper `ViewModifier`
  - Modifier must now be applied to the root view inside `WindowGroup`, not to `WindowGroup` itself
  - Updated documentation with correct usage pattern

### 📚 Documentation

- Updated README with correct usage example for session tracking modifier
- Clarified that modifier should be applied to root view, not `WindowGroup`

### 🔗 Links

- [GitHub Repository](https://github.com/featurepulse/feature-pulse-ios)
- [Release v1.0.5](https://github.com/featurepulse/feature-pulse-ios/releases/tag/1.0.5)

---

## [1.0.4] - 2025-01-28

### ✨ New Features

- **Session Tracking for Engagement Metrics** - Track user app opens to measure engagement
  - Simple `.featurePulseSessionTracking()` modifier - just add it to your `WindowGroup`
  - Automatic 30-minute timeout (Firebase-style) using UserDefaults
  - No configuration needed - modifier itself enables tracking
  - Tracks app opens when app becomes active (foreground)
  - Automatically calculates engagement weight for vote weighting
  - Shows engagement badges in dashboard (🔥 Power, ⚡ Active, 👍 Regular, 💤 Casual, 👻 Ghost)

### 🎯 Vote Weighting Enhancement

- **Engagement-Based Vote Weighting** - Votes now weighted by both MRR and engagement
  - Power users (20+ sessions/month): 2.0x engagement multiplier
  - Active users (10-19 sessions/month): 1.5x engagement multiplier
  - Regular users (5-9 sessions/month): 1.0x engagement multiplier
  - Casual users (2-4 sessions/month): 0.7x engagement multiplier
  - Ghost users (0-1 sessions/month): 0.3x engagement multiplier
  - Formula: `Vote Weight = MRR × Engagement Weight`

### 📚 Developer Experience

- **Simplified API** - One modifier, zero configuration
  - Just add `.featurePulseSessionTracking()` to your `WindowGroup`
  - No boolean flags or manual setup required
  - Comprehensive documentation with examples

### 📱 Requirements

- iOS 17.0+ (iPadOS included)
- Xcode 15.0+
- Swift 5.9+

### 🔗 Links

- [GitHub Repository](https://github.com/featurepulse/feature-pulse-ios)
- [Release v1.0.4](https://github.com/featurepulse/feature-pulse-ios/releases/tag/1.0.4)

---

## [1.0.3] - 2025-01-28

### 🐛 Bug Fixes

- **Deterministic Shuffle** - Fixed feature request order changing after voting
  - Replaced Swift's `Hasher` with djb2 hash algorithm for true determinism
  - Feature requests now maintain consistent order across app launches
  - Each user sees their own stable, seeded order based on device ID

### 🧹 Code Quality

- Fixed SwiftLint `identifier_name` violations in shuffle algorithm
- Improved variable naming: `i`, `j` → `index`, `randomIndex`
- All SwiftLint checks passing

### 📱 Requirements

- iOS 17.0+ (iPadOS included)
- Xcode 15.0+
- Swift 5.9+

### 🔗 Links

- [GitHub Repository](https://github.com/featurepulse/feature-pulse-ios)
- [Release v1.0.3](https://github.com/featurepulse/feature-pulse-ios/releases/tag/1.0.3)

---

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

