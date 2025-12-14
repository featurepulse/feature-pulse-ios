import Foundation

/// Defines how to handle feature request restrictions
public enum FeatureRequestRestrictionMode: Sendable {
    /// Show default alert with subscription name (defaults to "Pro")
    case alert(subscriptionName: String = "Pro")

    /// Custom callback - developer handles restriction (e.g., show paywall)
    case callback(@Sendable () -> Void)
}
