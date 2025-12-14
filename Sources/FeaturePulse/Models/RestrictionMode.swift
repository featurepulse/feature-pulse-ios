import Foundation

public extension FeaturePulse {
    enum RestrictionMode {
        /// Show default alert with subscription name (defaults to "Pro")
        case alert(subscriptionName: String = "Pro")

        /// Custom callback - developer handles restriction (e.g., show paywall)
        case callback(@MainActor () -> Void)
    }
}

typealias RestrictionMode = FeaturePulse.RestrictionMode
