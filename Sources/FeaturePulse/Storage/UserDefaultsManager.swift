import Foundation

/// Centralized UserDefaults management for FeaturePulse SDK
enum UserDefaultsManager {
    // MARK: - Keys
    private enum Keys {
        static let deviceID = "se.featurepul.deviceID"
        static let lastSessionTime = "se.featurepul.lastSessionTime"
        static let sessionCount = "se.featurepul.sessionCount"
        static let ctaDismissed = "se.featurepul.ctaDismissed"
    }

    // MARK: - Device ID
    static var deviceID: String? {
        get { UserDefaults.standard.string(forKey: Keys.deviceID) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.deviceID) }
    }

    // MARK: - Session Tracking
    static var lastSessionTime: Double {
        get { UserDefaults.standard.double(forKey: Keys.lastSessionTime) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.lastSessionTime) }
    }

    static var sessionCount: Int {
        get { UserDefaults.standard.integer(forKey: Keys.sessionCount) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.sessionCount) }
    }

    // MARK: - CTA Banner
    static var ctaBannerDismissed: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.ctaDismissed) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.ctaDismissed) }
    }
}
