import SwiftUI

/// View modifier for automatic session tracking
public struct FeaturePulseSessionTracker: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase

    public func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    FeaturePulseConfiguration.shared.trackAppOpenIfNewSession()
                }
            }
    }
}

extension View {
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
    ///         FeaturePulseConfiguration.shared.apiKey = "your-api-key-here"
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
    public func featurePulseSessionTracking() -> some View {
        modifier(FeaturePulseSessionTracker())
    }
}

/// Main configuration object for FeaturePulse SDK
@Observable
public final class FeaturePulseConfiguration: @unchecked Sendable {
    public static let shared = FeaturePulseConfiguration()

    /// Your FeaturePulse API key (required)
    public var apiKey: String = ""

    /// Base URL for FeaturePulse API
    public var baseURL: String = "https://featurepul.se"

    /// Current user information
    public let user = User()

    /// Primary brand color used for vote and submit buttons (defaults to primary blue: #570df8)
    public var primaryColor: Color = Color(red: 87 / 255, green: 13 / 255, blue: 248 / 255)

    /// Foreground color for vote title and icons and new feature request button CTA
    public var foregroundColor: Color = Color(uiColor: .white)

    /// Whether to show status badges on feature requests (controlled from dashboard, default: false)
    /// This value is set automatically by the API and cannot be changed by the client
    public internal(set) var showStatus: Bool = false

    private let lastSessionKey = "FeaturePulse_LastSessionTime"

    private init() {}

    /// Track app open for engagement metrics (with 30-minute timeout)
    /// Called automatically by the featurePulseSessionTracking() modifier
    internal func trackAppOpenIfNewSession() {
        let lastSessionTime = UserDefaults.standard.double(forKey: lastSessionKey)
        let now = Date().timeIntervalSince1970

        // 30 minutes timeout (1800 seconds)
        if lastSessionTime == 0 || (now - lastSessionTime) > 1800 {
            Task {
                do {
                    try await FeaturePulseAPI.shared.trackActivity(type: "app_open")
                    // Only update UserDefaults if API call succeeds
                    UserDefaults.standard.set(now, forKey: lastSessionKey)
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
    /// FeaturePulseConfiguration.shared.updateUser(customID: "user_123")
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
    /// FeaturePulseConfiguration.shared.updateUser(payment: .free)
    ///
    /// // Weekly subscription - $2.99/week
    /// FeaturePulseConfiguration.shared.updateUser(payment: .weekly(2.99))
    ///
    /// // Monthly subscription - $7.99/month
    /// FeaturePulseConfiguration.shared.updateUser(payment: .monthly(7.99))
    ///
    /// // Yearly subscription - $79.99/year
    /// FeaturePulseConfiguration.shared.updateUser(payment: .yearly(79.99))
    ///
    /// // Lifetime purchase - $99.99 one-time
    /// FeaturePulseConfiguration.shared.updateUser(payment: .lifetime(99.99))
    ///
    /// // Lifetime with custom amortization (36 months instead of default 24)
    /// FeaturePulseConfiguration.shared.updateUser(payment: .lifetime(199.99, expectedLifetimeMonths: 36))
    /// ```
    public func updateUser(payment: Payment) {
        user.payment = payment
        Task {
            try? await FeaturePulseAPI.shared.syncUser()
        }
    }
}
