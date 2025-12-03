# FeaturePulse iOS SDK

A modern SwiftUI-only SDK for collecting and managing feature requests from your iOS app users.

## Features

✅ **SwiftUI-Only** - Pure SwiftUI implementation, no UIKit dependencies  
✅ **Modern Swift 6.0** - Uses `@Observable`, async/await, and Swift Concurrency  
✅ **Type-Safe Localization** - String Catalogs with compile-time checking  
✅ **Multi-Language Support** - English, Spanish, French, German included  
✅ **Customizable** - Override any translation or appearance setting  
✅ **Simple Integration** - Just 3 lines of code to get started

## Requirements

- iOS 17.0+
- macOS 14.0+
- Swift 6.0+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add FeaturePulse to your project in Xcode:

1. File > Add Package Dependencies
2. Enter package URL: `https://github.com/featurepulse/feature-pulse-ios`
3. Select version and add to your target

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/featurepulse/feature-pulse-ios", from: "1.0.0")
]
```

## Quick Start

### 1. Configure API Key

In your app's initialization (e.g., `@main` struct):

```swift
import SwiftUI
import FeaturePulse

@main
struct MyApp: App {
    init() {
        // Required: Your API key from featurepul.se
        FeaturePulseConfiguration.shared.apiKey = "your-api-key-here"
        
        // Optional: Customize primary color
        FeaturePulseConfiguration.shared.primaryColor = .red
        
        // Optional: Set user payment tier
        FeaturePulseConfiguration.shared.updateUser(payment: .free)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 2. Add to Your UI

Choose from multiple integration patterns:

## Usage Examples

### Example 1: In a Tab Bar

```swift
import SwiftUI
import FeaturePulse

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            FeaturePulseView()
                .tabItem {
                    Label("Feedback", systemImage: "lightbulb")
                }
        }
    }
}
```

### Example 2: As a Modal Sheet

Present with NavigationStack and close button:

```swift
import SwiftUI
import FeaturePulse

struct ContentView: View {
    @State private var show = false

    var body: some View {
        Button("Feature Requests") {
            show = true
        }
        .sheet(isPresented: $show) {
            NavigationStack {
                FeaturePulseView()
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            if #available(iOS 26, *) {
                                Button(role: .close) {
                                    show = false
                                }
                            } else {
                                Button {
                                    show = false
                                } label: {
                                    Label("Close", systemImage: "xmark")
                                }
                            }
                        }
                    }
            }
        }
    }
}
```

### Example 3: As a Navigation Link

```swift
import SwiftUI
import FeaturePulse

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    FeaturePulseView()
                } label: {
                    Label(FeaturePulse.L10n.featureRequests, systemImage: "lightbulb")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
```

### Example 4: As a Root View

```swift
import SwiftUI
import FeaturePulse

struct FeedbackView: View {
    var body: some View {
        NavigationStack {
            FeaturePulseView()
        }
    }
}
```

That's it! Your users can now submit and vote on feature requests.

## Configuration

### Complete Configuration Example

```swift
import FeaturePulse

// API Configuration
FeaturePulseConfiguration.shared.apiKey = "your-api-key-here"

// Appearance
FeaturePulseConfiguration.shared.primaryColor = .red

// User Information
FeaturePulseConfiguration.shared.updateUser(
    customID: "user_123",
    email: "user@example.com",
    name: "John Doe"
)

// Payment Tier (affects vote weighting)
FeaturePulseConfiguration.shared.updateUser(payment: .free)
FeaturePulseConfiguration.shared.updateUser(payment: .weekly(2.99))
FeaturePulseConfiguration.shared.updateUser(payment: .monthly(9.99))
FeaturePulseConfiguration.shared.updateUser(payment: .yearly(79.99))
FeaturePulseConfiguration.shared.updateUser(payment: .lifetime(199.99))
```

### Customize Colors

Change the primary color and foreground colors to match your app's brand:

```swift
// Primary color (used for vote buttons, submit button, and CTA button background)
FeaturePulseConfiguration.shared.primaryColor = .blue
FeaturePulseConfiguration.shared.primaryColor = .red
FeaturePulseConfiguration.shared.primaryColor = Color(red: 87/255, green: 13/255, blue: 248/255)

// Foreground color (used for titles and main content)
FeaturePulseConfiguration.shared.foregroundColor = .primary  // System primary (adapts to light/dark mode)
FeaturePulseConfiguration.shared.foregroundColor = .black    // Always black
FeaturePulseConfiguration.shared.foregroundColor = Color(uiColor: .label)  // System label (default)
FeaturePulseConfiguration.shared.foregroundColor = Color(red: 0.2, green: 0.2, blue: 0.2)  // Custom color

// Accent foreground color (used for buttons with colored backgrounds)
FeaturePulseConfiguration.shared.accentForegroundColor = .white  // Default: white
FeaturePulseConfiguration.shared.accentForegroundColor = .black   // For light backgrounds
FeaturePulseConfiguration.shared.accentForegroundColor = Color(red: 1.0, green: 1.0, blue: 1.0)  // Custom color
```

**Note:** 
- The default `foregroundColor` uses `Color(uiColor: .label)` which automatically adapts to light/dark mode
- The default `accentForegroundColor` is white, which works well with most primary colors
- Make sure accent foreground color has good contrast with your primary color for accessibility

### User Information

Track user information for better feedback and analytics:

```swift
// Update user details
FeaturePulseConfiguration.shared.updateUser(
    customID: "user_123",      // Your internal user ID
    email: "user@example.com", // User's email
    name: "John Doe"          // User's display name
)

// Update payment tier separately
FeaturePulseConfiguration.shared.updateUser(payment: .monthly(9.99))
```

### Payment Tracking & Vote Weighting

FeaturePulse uses Monthly Recurring Revenue (MRR) to weight votes, giving higher priority to paying customers:

```swift
// Free users
FeaturePulseConfiguration.shared.updateUser(payment: .free)

// Weekly subscription ($2.99/week = ~$12 MRR)
FeaturePulseConfiguration.shared.updateUser(payment: .weekly(2.99))

// Monthly subscription ($9.99/month = $9.99 MRR)
FeaturePulseConfiguration.shared.updateUser(payment: .monthly(9.99))

// Yearly subscription ($79.99/year = ~$6.67 MRR)
FeaturePulseConfiguration.shared.updateUser(payment: .yearly(79.99))

// Lifetime purchase ($199.99 amortized over 24 months = ~$8.33 MRR)
FeaturePulseConfiguration.shared.updateUser(payment: .lifetime(199.99))

// Custom lifetime amortization period
FeaturePulseConfiguration.shared.updateUser(
    payment: .lifetime(199.99, expectedLifetimeMonths: 36)
)
```

**How Vote Weighting Works:**
- Free users: Weight = 0 (vote is counted but not weighted)
- Paying users: Weight = MRR in cents (e.g., $9.99/month = 999 points)
- **Engagement multiplier**: Votes are also weighted by user engagement (see Session Tracking below)
- Final formula: `Vote Weight = MRR × Engagement Weight`
- This ensures feature requests from engaged, paying customers are prioritized

### Session Tracking & Engagement Metrics

Track user app opens to measure engagement and weight votes accordingly:

```swift
@main
struct YourApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .featurePulseSessionTracking()  // Add this modifier to your root view
        }
    }
}
```

**That's it!** No configuration needed. The modifier automatically:
- Tracks app opens when your app becomes active (foreground)
- Uses 30-minute timeout (Firebase-style) to avoid counting quick app switches
- Stores session data in UserDefaults
- Sends session data to FeaturePulse backend

**Engagement Tiers:**
- 🔥 **Power User** (20+ sessions/month): 2.0x engagement multiplier
- ⚡ **Active User** (10-19 sessions/month): 1.5x engagement multiplier
- 👍 **Regular User** (5-9 sessions/month): 1.0x engagement multiplier
- 💤 **Casual User** (2-4 sessions/month): 0.7x engagement multiplier
- 👻 **Ghost User** (0-1 sessions/month): 0.3x engagement multiplier

**Vote Weighting with Engagement:**
```swift
// Example: User with $10/month subscription
// - Power User (20+ sessions): $10 × 2.0 = 20 points per vote
// - Active User (10-19 sessions): $10 × 1.5 = 15 points per vote
// - Regular User (5-9 sessions): $10 × 1.0 = 10 points per vote
// - Casual User (2-4 sessions): $10 × 0.7 = 7 points per vote
// - Ghost User (0-1 sessions): $10 × 0.3 = 3 points per vote
```

**Benefits:**
- Rewards users who actually use your app
- Prevents one-time users from skewing priorities
- Shows engagement badges in dashboard
- Helps identify your most valuable users

### RevenueCat Integration Example

If you're using [RevenueCat](https://www.revenuecat.com/) for subscriptions, here's how to automatically sync payment info:

```swift
import FeaturePulse
import RevenueCat

// Call this when you receive customer info updates
func syncRevenueCatToFeaturePulse(userPurchases: UserPurchasesManager) {
    guard
        let customerInfo = userPurchases.customerInfo,
        userPurchases.subscriptionActive,
        let entitlement = customerInfo.entitlements[Constants.revenueCatEntitlementIdentifier],
        let currentOffering = userPurchases.offerings?.current
    else {
        FeaturePulseConfiguration.shared.updateUser(payment: .free)
        return
    }
    
    let productId = entitlement.productIdentifier
    guard let matchedPackage = currentOffering.availablePackages.first(where: {
        $0.storeProduct.productIdentifier == productId
    }) else {
        FeaturePulseConfiguration.shared.updateUser(payment: .free)
        return
    }
    
    let price = matchedPackage.storeProduct.price
    let payment: FeaturePulse.Payment = {
        switch matchedPackage.packageType {
        case .weekly:
            return .weekly(price)
        case .monthly:
            return .monthly(price)
        case .annual:
            return .yearly(price)
        case .lifetime:
            return .lifetime(price, expectedLifetimeMonths: 24)
        default:
            return .free
        }
    }()
    
    FeaturePulseConfiguration.shared.updateUser(payment: payment)
}
```

**Integration Tips:**
- Call this function whenever RevenueCat customer info updates
- Use `Purchases.shared.getCustomerInfo()` to get current state
- Set up a listener: `Purchases.shared.delegate = self`
- Votes will be weighted based on actual subscription price

## Localization

FeaturePulse includes translations for:

- 🇬🇧 English
- 🇪🇸 Spanish (Español)
- 🇫🇷 French (Français)
- 🇩🇪 German (Deutsch)

The SDK automatically uses the user's device language. No additional configuration needed!

### Adding More Languages

To add more languages:

1. Open `Localizable.xcstrings` in Xcode
2. Click "+" to add a new language
3. Translate all strings
4. Rebuild the package

## API Reference

### FeaturePulseConfiguration

Main configuration singleton:

```swift
// Required
FeaturePulseConfiguration.shared.apiKey: String

// Optional
FeaturePulseConfiguration.shared.primaryColor: Color

// Methods
FeaturePulseConfiguration.shared.updateUser(
    customID: String? = nil,
    email: String? = nil,
    name: String? = nil
)

FeaturePulseConfiguration.shared.updateUser(payment: Payment)
```

### Views

- `FeaturePulseView()` - Main view with feature requests list

### Payment Types

```swift
enum Payment {
    case free
    case weekly(Decimal)
    case monthly(Decimal)
    case yearly(Decimal)
    case lifetime(Decimal, expectedLifetimeMonths: Int = 24)
}
```

## Getting Your API Key

1. Sign up at [featurepul.se](https://featurepul.se)
2. Create a new project
3. Copy your API key from the project settings
4. Add it to your app configuration

## Troubleshooting

### "Invalid API Key" error

Make sure you've set your API key before presenting any FeaturePulse views:

```swift
FeaturePulseConfiguration.shared.apiKey = "your-api-key-here"
```

### Color not applying

Make sure to set the color before presenting the view:

```swift
@main
struct MyApp: App {
    init() {
        FeaturePulseConfiguration.shared.primaryColor = .red
    }
    // ...
}
```

## Example Projects

Check out example implementations:
- **Tab Bar Integration**: See Example 1 above
- **Modal Presentation**: See Example 2 above
- **Navigation Link**: See Example 3 above

## Privacy & Data Collection

FeaturePulse SDK includes a **Privacy Manifest** (`PrivacyInfo.xcprivacy`) that declares all data collection and API usage according to [Apple's Privacy Manifest requirements](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files).

### Data Collected

The SDK collects the following data (all optional except device identifier):

- **Device Identifier**: Persistent device ID for analytics and feature request attribution
- **Email Address**: Optional, user-provided for contact purposes
- **Display Name**: Optional, user-provided for personalization
- **Payment Information**: Optional, for MRR tracking (payment tier only, not payment details)
- **App Usage**: App opens and feature request submissions for engagement metrics

### Privacy Features

- ✅ **No Tracking**: The SDK does not track users across apps or websites
- ✅ **User Control**: Email and name are optional and user-provided
- ✅ **Privacy-First**: All data collection is transparent and declared in the privacy manifest
- ✅ **App Store Compliant**: Privacy manifest ensures App Store submission compliance

### For App Developers

When submitting your app to the App Store, Xcode will automatically merge the SDK's privacy manifest with your app's privacy manifest. No additional configuration needed!

## Support

- 🐛 Issues: [GitHub Issues](https://github.com/featurepulse/feature-pulse-ios/issues)

## License

MIT License - see LICENSE file for details

## Credits

Built with ❤️ using SwiftUI and modern Swift concurrency.

---

**Made by [FeaturePulse](https://featurepul.se)** - The simplest way to collect feature requests from your iOS app.
