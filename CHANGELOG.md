# Changelog

All notable changes to the FeaturePulse iOS SDK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.10.2] - 2026-04-24

### 🐛 Bug Fixes

- **Swift 6 concurrency** - Fixed data race errors with the Translation framework when building with Swift 6 language mode

### 📦 Installation

```swift
.package(url: "https://github.com/featurepulse/feature-pulse-ios.git", from: "1.10.2")
```

### 🔗 Links

- [Full Changelog](https://github.com/featurepulse/feature-pulse-ios/blob/main/CHANGELOG.md)
- [Documentation](https://featurepul.se)

---

## [1.10.1] - 2026-03-28

### 🐛 Bug Fixes

- **Completed tab empty state** - Shows a dedicated empty state when no completed features exist
- **Tab reset on submit** - Submitting a new feature request switches back to the Requests tab automatically

### 📦 Installation

```swift
.package(url: "https://github.com/featurepulse/feature-pulse-ios.git", from: "1.10.1")
```

### 🔗 Links

- [Full Changelog](https://github.com/featurepulse/feature-pulse-ios/blob/main/CHANGELOG.md)
- [Documentation](https://featurepul.se)

---

## [1.10.0] - 2026-03-28

### ✨ New Features

- **Requests / Completed tabs** - Toolbar picker to switch between active feature requests and completed ones
- **Sorting** - Sort requests by Top (most votes) or Newest, with reset option
- **All users can submit** - Feature request submission no longer requires a premium subscription
- **Chinese Simplified localization** - Added zh-Hans support

### 📦 Installation

```swift
.package(url: "https://github.com/featurepulse/feature-pulse-ios.git", from: "1.10.0")
```

### 🔗 Links

- [Full Changelog](https://github.com/featurepulse/feature-pulse-ios/blob/main/CHANGELOG.md)
- [Documentation](https://featurepul.se)

---

## [1.9.0] - 2026-03-23

### ✨ New Features

- **macOS Support** - SDK now supports macOS 14.0+ alongside iOS 17.0+

### 📦 Installation

```swift
.package(url: "https://github.com/featurepulse/feature-pulse-ios.git", from: "1.9.0")
```

### 🔗 Links

- [Full Changelog](https://github.com/featurepulse/feature-pulse-ios/blob/main/CHANGELOG.md)
- [Documentation](https://featurepul.se)

---

## [1.8.0] - 2026-02-09

### ✨ New Features

- **API-Driven Status Appearance** - Status colors and icons now configurable from the dashboard
- **New "Planned" Status** - New status between approved and in progress
- **Owner-Aware Status Badges** - Approved badge only visible to the request creator

### 📦 Installation

```swift
.package(url: "https://github.com/featurepulse/feature-pulse-ios.git", from: "1.8.0")
```

### 🔗 Links

- [Full Changelog](https://github.com/featurepulse/feature-pulse-ios/blob/main/CHANGELOG.md)
- [Documentation](https://featurepul.se)

---

## [1.7.0] - 2025-01-27

### ✨ New Features

- **Watermark Control** - API-controlled "Powered by FeaturePulse" branding
  - Free tier users see watermark branding in the SDK
  - Premium/Enterprise users have watermark hidden automatically
  - No SDK configuration needed - controlled entirely from your subscription

- **Thank You Toast** - Shows confirmation after submitting feedback
  - Instant toast notification with checkmark animation
  - Auto-dismisses after the new request is highlighted
  - Localized in all supported languages

- **Scroll & Highlight New Requests** - Better UX after submission
  - Automatically scrolls to the newly created feature request
  - Highlights with a border animation for 2 seconds
  - Smooth `.smooth(duration: 0.5)` animation

### 🔧 Improvements

- **Type-Safe API Layer** - Refactored internal networking
  - New `APIEndpoint` enum for type-safe endpoint definitions
  - Generic `NetworkClient` with async/await support
  - Cleaner separation of concerns with dedicated response/request models

### 📦 Installation

```swift
.package(url: "https://github.com/featurepulse/feature-pulse-ios.git", from: "1.7.0")
```

### 🔗 Links

- [Full Changelog](https://github.com/featurepulse/feature-pulse-ios/blob/main/CHANGELOG.md)
- [Documentation](https://featurepul.se)

---

## [1.6.3] - 2025-12-26

### 🔧 Improvements

- **Improved CTA banner sheet presentation** - Enhanced reliability and smoothness when opening FeaturePulse view

## [1.6.2] - 2025-12-26

### 🔧 Improvements

- **Enhanced CTA banner animations** - Refactored to use proper SwiftUI transitions
  - Now uses native `.transition()` modifier for smoother animations
  - Scale + fade effect for modern feel
  - Cleaner, more maintainable code

## [1.6.1] - 2025-12-26

### 🐛 Bug Fixes

- **Fixed dependency scanning warning** - Changed RevenueCat integration to extension pattern
  - Removed built-in RevenueCat integration file to prevent dependency conflicts
  - No forced dependencies for users who don't use RevenueCat
  - Users can add extension to their own project (see README)
  - Clean builds with no warnings for all users

## [1.6.0] - 2025-12-26

### ✨ New Features

- **CTA Banner** - New method to encourage users to share feedback with a dismissible banner
  - `ctaBanner(trigger:icon:text:)` method to display on home screens
  - Auto trigger mode: Shows after X sessions (default: 3, requires session tracking)
  - Manual trigger mode: Custom condition closure for flexible control
  - Shows once until dismissed, never appears again
  - Customizable SF Symbol icon (default: "lightbulb.fill")
  - Customizable text with full multi-language support
  - Smooth slide-in animation and haptic feedback

## [1.5.0] - 2025-12-26

### ✨ New Features

- **RevenueCat Integration** - Added built-in convenience method for automatic payment syncing
  - New `updateUserFromRevenueCat(customerInfo:offerings:entitlementID:expectedLifetimeMonths:)` method
  - Automatically matches entitlement to StoreKit product for accurate pricing
  - Gets price and currency directly from StoreKit `storeProduct`
  - Uses `packageType` for reliable subscription period detection (weekly, monthly, yearly, lifetime)
  - Optional `expectedLifetimeMonths` parameter for lifetime purchase amortization (default: 24)
  - Automatically sets user to free if no active entitlement found
  - Only available when RevenueCat SDK is imported (uses conditional compilation)

### 📝 Changes

- **Updated README** - Added RevenueCat Integration section with built-in method examples
  - Shows recommended built-in method usage
  - Includes custom implementation example for advanced users
  - Documents how the integration works and its benefits

## [1.4.4] - 2025-12-15

### 🐛 Bug Fixes

- **Fixed translation button state during language download** - Button no longer toggles to "See Original" prematurely
  - Added language availability checking using Apple's `LanguageAvailability` API
  - Button only toggles to "See Original" after translation language is fully downloaded and installed
  - Automatically re-checks availability when user taps button if language wasn't installed

## [1.4.3] - 2025-12-15

### ✨ New Features

- **Haptic feedback on vote action** - Added sensory feedback when users vote or unvote
  - Provides tactile confirmation of successful vote actions
  - Applied to both list view and detail view vote buttons
  - Uses `.sensoryFeedback(.success)` modifier for native iOS haptics

### 🐛 Bug Fixes

- **Fixed translation caching** - Translations now persist when toggling off/on
  - Removed `translations.removeAll()` and `translationConfig = nil` when disabling translations
  - Translations are now cached in memory for instant re-display
  - Significantly improves UX for users toggling between original and translated text
  - No need to re-fetch translations from Apple's Translation API

## [1.4.2] - 2025-12-14

### 🐛 Bug Fixes

- **Fixed translate button text color** - Removed incorrect foreground color override
  - The translate button now properly inherits system colors for better readability
  - Previously used custom foreground color that could cause visibility issues

## [1.4.1] - 2025-12-14

### 🐛 Bug Fixes

- **Fixed ambiguous type lookup error** - Removed old renamed files from public SDK repository
  - Deleted `FeaturePulseConfiguration.swift` (renamed to `FeaturePulse.swift` in v1.4.0)
  - Deleted `FeatureRequestRestrictionMode.swift` (renamed to `RestrictionMode.swift` in v1.4.0)
  - This fixes "FeaturePulse is ambiguous for type lookup" error when adding the package remotely via SPM

### 🔧 Improvements

- **Enhanced release process** - Added automated release script and improved sync process
  - Uses `rsync --delete` to ensure clean syncing between monorepo and public repo
  - Prevents old renamed files from lingering in the public repository
  - Better verification steps before committing releases

## [1.4.0] - 2025-12-14

### ✨ New Features

- **Clean Nested Type Architecture** - Following Amplitude's pattern
  - `Payment` → `FeaturePulse.Payment`
  - `FeatureRequestRestrictionMode` → `FeaturePulse.RestrictionMode`
  - `FeaturePulseL10n` → `FeaturePulse.L10n`
  - Each type in separate file using extensions
  - Internal typealiases for SDK convenience
  - No naming collisions with module name

### 🔧 Improvements

- **Simplified Main Class** - Renamed `FeaturePulseConfiguration` → `FeaturePulse`
  - Removed unnecessary typealias
  - Cleaner, more intuitive API
  - File renamed to `FeaturePulse.swift`

- **Better Callback Support** - Changed `RestrictionMode.callback` to `@MainActor`
  - Can now capture `@State` properties
  - Perfect for showing paywalls and UI operations
  - Removed unnecessary `DispatchQueue.main.async` wrapper

- **Documentation Updates**
  - Removed generic/obvious comments
  - Updated payment examples to include required `currency` parameter
  - Clearer code documentation

### ⚠️ Breaking Changes

- **Main class renamed**: `FeaturePulseConfiguration` → `FeaturePulse`
  - If you used `FeaturePulseConfiguration.shared`, change to `FeaturePulse.shared`
  - Most users already used `FeaturePulse.shared` via typealias (no change needed)

- **Nested types**: Types are now nested under `FeaturePulse`
  - `Payment` → `FeaturePulse.Payment` (internal typealias for compatibility)
  - `FeatureRequestRestrictionMode` → `FeaturePulse.RestrictionMode` (internal typealias for compatibility)
  - `FeaturePulseL10n` → `FeaturePulse.L10n`
  - **Usage with type inference is unchanged**: `.free`, `.monthly()`, etc. still work

- **RestrictionMode callback**: Changed from `@Sendable` to `@MainActor`
  - More flexible, allows capturing UI state
  - No impact unless you relied on Sendable conformance

### 📦 Migration Guide

Most code works without changes due to type inference:

```swift
// Before (still works)
FeaturePulse.shared.updateUser(payment: .free)
FeaturePulse.shared.restrictionMode = .alert(subscriptionName: "Pro")

// Explicit type references (if you have them)
// Before: let payment: Payment = .free
// After:  let payment: FeaturePulse.Payment = .free

// Localization
// Before: Label(FeaturePulseL10n.featureRequests, ...)
// After:  Label(FeaturePulse.L10n.featureRequests, ...)
```

### 🔗 Links

- [Full Changelog](https://github.com/featurepulse/feature-pulse-ios/blob/main/CHANGELOG.md)
- [Documentation](https://featurepul.se)

---

## [1.3.2] - 2025-12-14

### 🐛 Bug Fixes

- **Internal L10n Improvements** - Optimized localization implementation
  - Refined internal typealias usage for better SDK consistency
  - Improved localization architecture for maintainability

### 🔗 Links

- [Full Changelog](https://github.com/featurepulse/feature-pulse-ios/blob/main/CHANGELOG.md)
- [Documentation](https://featurepul.se)

---

## [1.3.1] - 2025-12-14

### 🐛 Bug Fixes

- **Fixed Naming Collision** - Renamed `L10n` to `FeaturePulseL10n`
  - Prevents conflicts with user projects that have their own `L10n` type
  - All SDK references updated to use `FeaturePulseL10n`
  - Updated documentation and examples

### 🔗 Links

- [Full Changelog](https://github.com/featurepulse/feature-pulse-ios/blob/main/CHANGELOG.md)
- [Documentation](https://featurepul.se)

---

## [1.3.0] - 2025-12-14

### ✨ New Features

- **Dashboard Translation Control** - Control translation button visibility from web dashboard
  - New `show_translation` setting in project settings (default: `true`)
  - Dashboard toggle to enable/disable translation button for non-English users
  - Requires premium plan to access control
  - Properly respects dashboard setting in iOS SDK

### 🔗 Links

- [Full Changelog](https://github.com/featurepulse/feature-pulse-ios/blob/main/CHANGELOG.md)
- [Documentation](https://featurepul.se)

---

## [1.2.0] - 2025-12-14

### ✨ New Features

- **Feature Request Restrictions** - Restrict feature creation to paying users
  - Dashboard toggle to require subscription for creating feature requests
  - Free users can still vote on existing requests
  - Two restriction modes:
    - `.alert(subscriptionName:)` - Show alert with customizable subscription name (default: "Pro")
    - `.callback` - Custom handler for showing paywalls or navigation
  - Checks `payment_type` instead of MRR (supports gifted subscriptions with $0 MRR)
  - All three "Request Feature" buttons respect permissions (toolbar, CTA, empty state)

- **Clean API with Typealias** - Shorter, more elegant SDK usage
  - `FeaturePulse` typealias for `FeaturePulseConfiguration`
  - Use `FeaturePulse.shared` instead of `FeaturePulseConfiguration.shared`
  - New `view()` convenience method: `FeaturePulse.shared.view()` returns `FeaturePulseView` instance

- **Safe Enum Decoding** - Resilient to unknown enum values from API
  - `@Default<FirstCase>` property wrapper for enum properties
  - Prevents crashes when API returns unknown status values
  - Automatically falls back to first case if value is unrecognized

### 🎨 API Improvements

- Simplified restriction configuration:
  ```swift
  // Default - shows alert with "Pro"
  // No configuration needed

  // Custom subscription name
  FeaturePulse.shared.restrictionMode = .alert(subscriptionName: "Premium")

  // Custom callback
  FeaturePulse.shared.restrictionMode = .callback {
      showPaywallSheet()
  }
  ```

- Cleaner SDK initialization:
  ```swift
  // Old
  FeaturePulseConfiguration.shared.apiKey = "key"

  // New
  FeaturePulse.shared.apiKey = "key"
  ```

- Convenient view instantiation:
  ```swift
  // Direct instantiation (still works)
  FeaturePulseView()

  // New convenience method
  FeaturePulse.shared.view()
  ```

### 🔒 Restriction Behavior

- **Paid users** (weekly, monthly, yearly, lifetime) → Can create feature requests
- **Gifted subscriptions** → Can create (even with $0 MRR)
- **Free users** → Cannot create, see restriction message
- **Everyone** → Can vote on existing requests

### 📚 Documentation

- Updated README with new API examples
- Added Feature Request Restrictions section
- Documented restriction modes and usage patterns
- Updated all code examples to use `FeaturePulse.shared`
- Added API reference for `FeatureRequestRestrictionMode`

### 🔗 Links

- [GitHub Repository](https://github.com/featurepulse/feature-pulse-ios)
- [Release v1.2.0](https://github.com/featurepulse/feature-pulse-ios/releases/tag/ios-sdk-v1.2.0)

---

## [1.1.1] - 2025-12-12

### ✨ New Features

- **Empty State View** - Added beautiful empty state when no feature requests exist
  - Localized empty state messages in all supported languages
  - Encourages users to submit their first feature request
  - Clean, minimalist design with clear call-to-action

### 🎨 UI Improvements

- **Enhanced Animations** - Improved animation smoothness in feature request rows
  - Better visual feedback when interacting with feature requests
  - Smoother transitions and state changes
  - More polished overall user experience

### 🔗 Links

- [GitHub Repository](https://github.com/featurepulse/feature-pulse-ios)
- [Release v1.1.1](https://github.com/featurepulse/feature-pulse-ios/releases/tag/1.1.1)

---

## [1.1.0] - 2025-02-05

### 🌍 Multi-Currency Support

- **BREAKING**: Currency parameter is now **required** for all payment tiers (except `.free`)
  - `Payment.weekly(_:currency:)` - Currency parameter added
  - `Payment.monthly(_:currency:)` - Currency parameter added
  - `Payment.yearly(_:currency:)` - Currency parameter added
  - `Payment.lifetime(_:currency:expectedLifetimeMonths:)` - Currency parameter added
- **20+ Currencies Supported** - USD, EUR, GBP, CAD, AUD, JPY, CHF, CNY, INR, BRL, MXN, SEK, NOK, DKK, PLN, SGD, HKD, KRW, TRY, ZAR
- **Automatic Conversion** - All amounts converted to USD for MRR calculations while preserving original currency
- **ISO 4217 Standard** - Use standard currency codes (e.g., "USD", "EUR", "GBP")

### 📝 Migration Guide

Update your payment configuration to include currency:

```swift
// Before (1.0.x)
FeaturePulseConfiguration.shared.updateUser(payment: .monthly(9.99))

// After (1.1.0)
FeaturePulseConfiguration.shared.updateUser(payment: .monthly(9.99, currency: "USD"))
```

RevenueCat integration also updated:

```swift
let currency = matchedPackage.storeProduct.currencyCode ?? "USD"
let payment: FeaturePulse.Payment = {
    switch matchedPackage.packageType {
    case .monthly:
        return .monthly(price, currency: currency)
    // ... other cases
    }
}()
```

### 🔗 Links

- [GitHub Repository](https://github.com/featurepulse/feature-pulse-ios)
- [Release v1.1.0](https://github.com/featurepulse/feature-pulse-ios/releases/tag/1.1.0)

---

## [1.0.10] - 2025-01-30

### 📚 Documentation

- **Updated README** - Improved clarity and focus
  - Removed vote weighting terminology (simplified to payment tracking)
  - Removed troubleshooting section
  - Removed redundant example projects section
  - Clearer focus on MRR tracking and user engagement insights

### 🔗 Links

- [GitHub Repository](https://github.com/featurepulse/feature-pulse-ios)
- [Release v1.0.10](https://github.com/featurepulse/feature-pulse-ios/releases/tag/1.0.10)

---

## [1.0.9] - 2025-01-30

### 🔒 Privacy & Simplification

- **Removed Email Collection** - Email field completely removed from SDK for better privacy
  - No more email input field in new feature request form
  - Users are now tracked by device ID only
  - Simplified user model (removed email and name properties)
  - Updated privacy manifest to reflect minimal data collection

- **Added Custom User ID Support** - New method to link device ID with your internal user system
  - `updateUser(customID:)` method for tracking users across your systems
  - Useful for linking feature requests to your authentication system
  - Does not change privacy manifest (covered under existing User ID declaration)

- **Privacy Manifest Improvements**
  - Removed email and name from collected data types
  - Now only collects: Device ID, Payment tier, and App usage
  - Fully compliant with Apple's privacy requirements
  - Added `PrivacyInfo.xcprivacy` to package resources

### 📚 Documentation

- Updated README to reflect privacy-first approach
- Removed email-related configuration examples
- Added Custom User ID documentation
- Clarified privacy manifest and data collection policies

### 🔗 Links

- [GitHub Repository](https://github.com/featurepulse/feature-pulse-ios)
- [Release v1.0.9](https://github.com/featurepulse/feature-pulse-ios/releases/tag/1.0.9)

---

## [1.0.8] - 2025-01-30

### 🔧 Maintenance

- **Package Cache Fix** - New version to resolve Xcode package cache issues after tag update

### 🔗 Links

- [GitHub Repository](https://github.com/featurepulse/feature-pulse-ios)
- [Release 1.0.8](https://github.com/featurepulse/feature-pulse-ios/releases/tag/1.0.8)

---

## [1.0.7] - 2025-01-30

### 🌍 Localization

- **Italian (IT) Support** - Added complete Italian translations for all SDK strings
- **Portuguese (PT-PT) Support** - Added complete Portuguese (Portugal) translations for all SDK strings
- SDK now supports 6 languages: English, Spanish, French, German, Italian, and Portuguese (PT-PT)

### 🔗 Links

- [GitHub Repository](https://github.com/featurepulse/feature-pulse-ios)
- [Release v1.0.7](https://github.com/featurepulse/feature-pulse-ios/releases/tag/1.0.7)

---

## [1.0.6] - 2025-01-30

### ✨ New Features

- **Configurable Foreground Colors** - Enhanced color customization
  - `foregroundColor` - Configurable foreground color for vote buttons, submit button, and CTA button
  - Defaults to white for optimal contrast with primary color backgrounds
  - Allows full customization of button text and icon colors

### 🔧 Improvements

- **Color Configuration** - Improved color property naming
  - Renamed `textColor` to `foregroundColor` for better SwiftUI terminology alignment
  - More accurate naming reflects that colors apply to all foreground elements, not just text

### 📚 Documentation

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
