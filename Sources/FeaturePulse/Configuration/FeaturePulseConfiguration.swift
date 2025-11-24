import SwiftUI

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

    private init() {}

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
