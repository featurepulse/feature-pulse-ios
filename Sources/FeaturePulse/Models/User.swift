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

    /// Returns the user identifier to send with API requests
    /// Always uses deviceID as the stable unique identifier
    /// customID and email are sent as additional metadata to complement the device identity
    var userIdentifier: String {
        deviceID
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
