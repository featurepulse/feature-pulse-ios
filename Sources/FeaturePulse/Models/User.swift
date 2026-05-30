import Foundation

/// Represents the current user of the SDK
final class User: @unchecked Sendable {
    /// Custom user identifier (e.g., your app's user ID)
    var customID: String?

    /// User's payment information for MRR tracking
    var payment: Payment?

    /// Unique device identifier persisted locally for this app install.
    private(set) var deviceID: String

    private static let deviceIDQueue = DispatchQueue(label: "se.featurepul.device-id")

    init() {
        deviceID = Self.getOrCreateDeviceID()
    }

    /// Returns the canonical user identifier to send with API requests.
    /// Signed-in apps use customID so the same account matches across devices.
    var userIdentifier: String {
        customID ?? deviceID
    }

    // MARK: - Private Helpers

    private static func getOrCreateDeviceID() -> String {
        deviceIDQueue.sync {
            if !DeviceIDMigration.isCompleted, let legacyID = DeviceIDMigration.legacyDeviceID {
                UserDefaultsManager.deviceID = legacyID
                DeviceIDMigration.isCompleted = true
                return legacyID
            }

            if let cachedID = UserDefaultsManager.deviceID {
                return cachedID
            }

            let newID = UUID().uuidString
            UserDefaultsManager.deviceID = newID
            DeviceIDMigration.isCompleted = true
            return newID
        }
    }
}
