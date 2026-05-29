import Foundation

/// Centralized UserDefaults management for FeaturePulse SDK
enum UserDefaultsManager {
    private static var defaults: UserDefaults {
        UserDefaults(suiteName: "se.featurepul.defaults") ?? .standard
    }

    // MARK: - Keys
    enum Keys {
        static let deviceID = "se.featurepul.deviceID"
        static let lastSessionTime = "se.featurepul.lastSessionTime"
        static let sessionCount = "se.featurepul.sessionCount"
        static let ctaDismissed = "se.featurepul.ctaDismissed"
        static let lastSyncedCustomID = "se.featurepul.lastSyncedCustomID"
        static let lastSyncedPayment = "se.featurepul.lastSyncedPayment"
        static let isUserActive = "se.featurepul.isUserActive"
    }

    // MARK: - Device ID
    static var deviceID: String? {
        get { defaults.string(forKey: Keys.deviceID) }
        set { set(newValue, forKey: Keys.deviceID) }
    }

    // MARK: - Session Tracking
    static var lastSessionTime: Double {
        get { defaults.double(forKey: Keys.lastSessionTime) }
        set { defaults.set(newValue, forKey: Keys.lastSessionTime) }
    }

    static var sessionCount: Int {
        get { defaults.integer(forKey: Keys.sessionCount) }
        set { defaults.set(newValue, forKey: Keys.sessionCount) }
    }

    // MARK: - CTA Banner
    static var ctaBannerDismissed: Bool {
        get { defaults.bool(forKey: Keys.ctaDismissed) }
        set { defaults.set(newValue, forKey: Keys.ctaDismissed) }
    }

    // MARK: - User Sync Cache
    static var lastSyncedCustomID: String? {
        get { defaults.string(forKey: Keys.lastSyncedCustomID) }
        set { set(newValue, forKey: Keys.lastSyncedCustomID) }
    }

    static var isUserActive: Bool {
        get { defaults.bool(forKey: Keys.isUserActive) }
        set { defaults.set(newValue, forKey: Keys.isUserActive) }
    }

    static var lastSyncedPayment: Payment? {
        get {
            guard let data = defaults.data(forKey: Keys.lastSyncedPayment) else { return nil }
            return try? JSONDecoder().decode(Payment.self, from: data)
        }
        set {
            if let value = newValue, let data = try? JSONEncoder().encode(value) {
                defaults.set(data, forKey: Keys.lastSyncedPayment)
            } else {
                defaults.removeObject(forKey: Keys.lastSyncedPayment)
            }
        }
    }

    static func removeObject(forKey key: String) {
        defaults.removeObject(forKey: key)
        UserDefaults.standard.removeObject(forKey: key)
    }

    private static func set(_ value: String?, forKey key: String) {
        if let value {
            defaults.set(value, forKey: key)
        } else {
            defaults.removeObject(forKey: key)
        }
    }
}

enum DeviceIDMigration {
    private static let migrationCompletedKey = "se.featurepul.legacyDeviceIDMigrationCompleted"
    private static let legacyStableIDKey = "_StableID_Identifier"

    private static var legacyStableIDDefaults: UserDefaults? {
        UserDefaults(suiteName: "_StableID_DefaultsSuiteName")
    }

    static var isCompleted: Bool {
        get { UserDefaults.standard.bool(forKey: migrationCompletedKey) }
        set { UserDefaults.standard.set(newValue, forKey: migrationCompletedKey) }
    }

    static var legacyDeviceID: String? {
        if let cachedID = UserDefaults.standard.string(forKey: UserDefaultsManager.Keys.deviceID), !cachedID.isEmpty {
            return cachedID
        }

        if let stableID = legacyStableIDDefaults?.string(forKey: legacyStableIDKey), !stableID.isEmpty {
            return stableID
        }

        return nil
    }

    static func resetForTests() {
        UserDefaults.standard.removeObject(forKey: migrationCompletedKey)
        legacyStableIDDefaults?.removeObject(forKey: legacyStableIDKey)
    }
}
