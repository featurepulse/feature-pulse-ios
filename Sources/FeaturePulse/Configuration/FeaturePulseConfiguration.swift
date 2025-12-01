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
    /// Simply add this modifier to enable session tracking. No configuration needed!
    ///
    /// # Example Usage:
    /// ```swift
    /// @main
    /// struct YourApp: App {
    ///     var body: some Scene {
    ///         WindowGroup {
    ///             ContentView()
    ///         }
    ///         .featurePulseSessionTracking()
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

    /// Primary brand color used for vote and submit buttons (defaults to DaisyUI primary blue: #570df8)
    public var primaryColor: Color = Color(red: 87 / 255, green: 13 / 255, blue: 248 / 255)

    /// Whether to show status badges on feature requests (controlled from dashboard, default: false)
    /// This value is set automatically by the API and cannot be changed by the client
    public internal(set) var showStatus: Bool = false

    /// Whether to show the email field in the new feature request form (controlled from dashboard, default: false)
    /// This value is set automatically by the API and cannot be changed by the client
    /// Default is false (email field hidden) for better privacy
    public internal(set) var showSdkEmailField: Bool = false

    private let lastSessionKey = "FeaturePulse_LastSessionTime"

    private init() {}

    /// Track app open for engagement metrics (with 30-minute timeout)
    /// Called automatically by the featurePulseSessionTracking() modifier
    internal func trackAppOpenIfNewSession() {
        let lastSessionTime = UserDefaults.standard.double(forKey: lastSessionKey)
        let now = Date().timeIntervalSince1970

        // 30 minutes timeout (1800 seconds)
        if lastSessionTime == 0 || (now - lastSessionTime) > 1800 {
            UserDefaults.standard.set(now, forKey: lastSessionKey)

            Task {
                try? await FeaturePulseAPI.shared.trackActivity(type: "app_open")
            }
        }
    }

    /// Update user with multiple properties
    public func updateUser(customID: String? = nil, email: String? = nil, name: String? = nil) {
        if let customID = customID {
            user.customID = customID
        }
        if let email = email {
            user.email = email
        }
        if let name = name {
            user.name = name
        }
        Task {
            do {
                try await FeaturePulseAPI.shared.syncUser()
            } catch {
                // Silently handle sync errors
            }
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
