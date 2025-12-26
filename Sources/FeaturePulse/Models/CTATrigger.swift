import Foundation

public extension FeaturePulse {
    /// Defines when the CTA banner should be shown
    enum CTATrigger {
        /// Automatically show after user has completed a minimum number of app sessions
        /// Requires `.featurePulseSessionTracking()` modifier to be added to your root view
        case auto(minSessions: Int = 3)

        /// Manually control when to show using a custom condition
        case manual(() -> Bool)
    }
}
