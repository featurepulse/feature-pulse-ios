import SwiftUI

public struct FeaturePulseSessionTracker: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase

    public func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    FeaturePulse.shared.trackAppOpenIfNewSession()
                }
            }
    }
}

public extension View {
    /// Automatically track app sessions when the view becomes active
    /// Tracks app opens with a 30-minute timeout (Firebase-style)
    ///
    /// Simply add this modifier to your root view inside `WindowGroup` to enable session tracking. No configuration needed!
    ///
    /// # Example Usage:
    /// ```swift
    /// @main
    /// struct YourApp: App {
    ///     init() {
    ///         // Required: Your API key from featurepul.se
    ///         FeaturePulse.shared.apiKey = "your-api-key-here"
    ///     }
    ///
    ///     var body: some Scene {
    ///         WindowGroup {
    ///             ContentView()
    ///                 .featurePulseSessionTracking() // Add this modifier to your root view
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// # How It Works:
    /// - Tracks when app becomes active (foreground)
    /// - Uses 30-minute timeout (same as Firebase Analytics)
    /// - Stores last session time in UserDefaults
    /// - Automatically calculates engagement weight for votes
    /// - Shows engagement badges in dashboard (🔥 Power, ⚡ Active, etc.)
    ///
    /// # Engagement Tiers:
    /// - 🔥 Power User: 20+ sessions/month
    /// - ⚡ Active User: 10-19 sessions/month
    /// - 👍 Regular User: 5-9 sessions/month
    /// - 💤 Casual User: 2-4 sessions/month
    /// - 👻 Ghost User: 0-1 sessions/month
    func featurePulseSessionTracking() -> some View {
        modifier(FeaturePulseSessionTracker())
    }
}

@Observable
public final class FeaturePulse: @unchecked Sendable {
    public static let shared = FeaturePulse()

    /// Your FeaturePulse API key (required)
    public var apiKey: String = ""

    /// Base URL for FeaturePulse API
    public var baseURL: String = "https://featurepul.se"

    /// Current user information
    let user = User()

    /// Primary brand color used for vote and submit buttons (defaults to primary blue: #570df8)
    public var primaryColor: Color = .init(red: 87 / 255, green: 13 / 255, blue: 248 / 255)

    /// Foreground color for vote title and icons and new feature request button CTA
    public var foregroundColor: Color = .init(uiColor: .white)

    /// Whether to show status badges on feature requests (controlled from dashboard, default: false)
    /// This value is set automatically by the API and cannot be changed by the client
    public internal(set) var showStatus: Bool = false

    /// Whether to show translation button for non-English users (controlled from dashboard, default: true)
    /// This value is set automatically by the API and cannot be changed by the client
    /// Requires iOS 18.0+ to work
    public internal(set) var showTranslation: Bool = true

    /// User permissions (fetched from API)
    /// This value is set automatically by the API and cannot be changed by the client
    public internal(set) var permissions: Permissions = .init(canCreateFeatureRequest: true)

    /// How to handle feature request restrictions (nil = default alert with "Pro")
    public var restrictionMode: RestrictionMode?

    private init() {}

    /// Track app open for engagement metrics (with 30-minute timeout)
    /// Called automatically by the featurePulseSessionTracking() modifier
    func trackAppOpenIfNewSession() {
        let lastSessionTime = UserDefaultsManager.lastSessionTime
        let now = Date().timeIntervalSince1970

        // 30 minutes timeout (1800 seconds)
        if lastSessionTime == 0 || (now - lastSessionTime) > 1800 {
            Task {
                do {
                    try await FeaturePulseAPI.shared.trackActivity(type: "app_open")
                    // Only update UserDefaults if API call succeeds
                    UserDefaultsManager.lastSessionTime = now
                    UserDefaultsManager.sessionCount += 1
                } catch {
                    // Silently fail - don't block app, but don't mark as tracked if it failed
                    // Will retry on next app open (after 30 min)
                }
            }
        }
    }

    /// Update user with custom ID for tracking
    /// - Parameters:
    ///   - customID: Your internal user ID (e.g., from your authentication system)
    ///
    /// # Example Usage:
    /// ```swift
    /// FeaturePulse.shared.updateUser(customID: "user_123")
    /// ```
    public func updateUser(customID: String?) {
        user.customID = customID
        Task {
            try? await FeaturePulseAPI.shared.syncUser()
        }
    }

    /// Update user with payment information for MRR tracking
    /// - Parameters:
    ///   - payment: The user's payment tier (free, weekly, monthly, yearly, or lifetime)
    ///
    /// # Example Usage:
    /// ```swift
    /// // Free user
    /// FeaturePulse.shared.updateUser(payment: .free)
    ///
    /// // Weekly subscription - $2.99/week
    /// FeaturePulse.shared.updateUser(payment: .weekly(2.99, currency: "USD"))
    ///
    /// // Monthly subscription - $7.99/month
    /// FeaturePulse.shared.updateUser(payment: .monthly(7.99, currency: "USD"))
    ///
    /// // Yearly subscription - $79.99/year
    /// FeaturePulse.shared.updateUser(payment: .yearly(79.99, currency: "USD"))
    ///
    /// // Lifetime purchase - $99.99 one-time
    /// FeaturePulse.shared.updateUser(payment: .lifetime(99.99, currency: "USD"))
    ///
    /// // Lifetime with custom amortization (36 months instead of default 24)
    /// FeaturePulse.shared.updateUser(payment: .lifetime(199.99, currency: "USD", expectedLifetimeMonths: 36))
    /// ```
    public func updateUser(payment: Payment) {
        user.payment = payment
        Task {
            try? await FeaturePulseAPI.shared.syncUser()
        }
    }

    /// Returns a FeaturePulseView instance
    ///
    /// # Example Usage:
    /// ```swift
    /// // In a NavigationStack or TabView
    /// FeaturePulse.shared.view()
    /// ```
    @MainActor public func view() -> FeaturePulseView {
        FeaturePulseView()
    }

    /// Returns a CTA banner that encourages users to share feedback
    ///
    /// The banner shows once until dismissed, then never appears again.
    /// Perfect for home screens to remind users they can share feedback.
    ///
    /// # Example Usage:
    /// ```swift
    /// var body: some View {
    ///     VStack {
    ///         // Auto mode - show after 3 sessions (default)
    ///         FeaturePulse.shared.ctaBanner()
    ///
    ///         // Auto mode - show after 5 sessions
    ///         FeaturePulse.shared.ctaBanner(trigger: .auto(minSessions: 5))
    ///
    ///         // Manual mode - custom condition
    ///         FeaturePulse.shared.ctaBanner(trigger: .manual {
    ///             hasCompletedOnboarding && isPremiumUser
    ///         })
    ///
    ///         // Rest of your home screen content
    ///         HomeScreenContent()
    ///     }
    /// }
    /// ```
    ///
    /// # Customization:
    /// ```swift
    /// // Custom icon and text
    /// FeaturePulse.shared.ctaBanner(
    ///     trigger: .auto(),
    ///     icon: "star.fill",
    ///     text: "Help us improve the app!"
    /// )
    /// ```
    ///
    /// # Parameters:
    /// - trigger: When to show the banner (default: `.auto(minSessions: 3)`)
    ///   - `.auto(minSessions: Int)`: Show after X sessions (requires session tracking modifier)
    ///   - `.manual(() -> Bool)`: Custom condition closure
    /// - icon: SF Symbol name for the icon (default: "lightbulb.fill")
    /// - text: Custom message text (default: localized "Share your feedback!")
    ///
    /// # Behavior:
    /// - Returns `nil` if trigger condition not met or already dismissed
    /// - Tapping banner opens FeaturePulse view and dismisses permanently
    /// - Tapping X dismisses permanently (stored in UserDefaults)
    /// - Smooth slide-in animation on first appearance
    /// - Haptic feedback on dismiss
    ///
    /// # Auto Mode Requirements:
    /// For `.auto()` to work, add session tracking to your root view:
    /// ```swift
    /// WindowGroup {
    ///     ContentView()
    ///         .featurePulseSessionTracking()
    /// }
    /// ```
    @MainActor public func ctaBanner(
        trigger: CTATrigger = .auto(),
        icon: String = "lightbulb.fill",
        text: String? = nil
    ) -> some View {
        CTABannerContainer(trigger: trigger, icon: icon, text: text)
    }
}

/// Container view that handles CTA banner animations
private struct CTABannerContainer: View {
    let trigger: FeaturePulse.CTATrigger
    let icon: String
    let text: String?

    @State private var isVisible = false
    @State private var isDismissed = UserDefaultsManager.ctaBannerDismissed

    var body: some View {
        Group {
            let shouldShow: Bool = {
                switch trigger {
                case .auto(let minSessions):
                    return UserDefaultsManager.sessionCount >= minSessions
                case .manual(let condition):
                    return condition()
                }
            }()

            if shouldShow && !isDismissed && isVisible {
                CTABannerView(icon: icon, text: text) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isDismissed = true
                    }
                    UserDefaultsManager.ctaBannerDismissed = true
                }
            }
        }
        .task {
            // Delay appearance for smooth entry
            try? await Task.sleep(for: .milliseconds(300))
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isVisible = true
            }
        }
    }
}
