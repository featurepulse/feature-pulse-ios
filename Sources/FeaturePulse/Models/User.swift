import Foundation
import StableID

/// Represents the current user of the SDK
final class User: @unchecked Sendable {
    /// Custom user identifier (e.g., your app's user ID)
    var customID: String?

    /// User's payment information for MRR tracking
    var payment: Payment?

    /// Unique device identifier (persisted in Keychain, survives app reinstalls)
    private(set) var deviceID: String

    init() {
        // Use StableID for persistent device identification
        // Stored in Keychain and iCloud (when available), survives app reinstalls

        #if targetEnvironment(simulator)
            // For simulator, generate a stable UUID stored in UserDefaults
            // (iCloud Key-Value Store requires entitlements that may not be configured)
            if let stored = UserDefaultsManager.deviceID {
                deviceID = stored
            } else {
                deviceID = UUID().uuidString
                UserDefaultsManager.deviceID = deviceID
            }
        #else
            // For real devices, use StableID which syncs across devices via iCloud
            if !StableID.isConfigured {
                StableID.configure()
            }
            deviceID = StableID.id
        #endif
    }

    /// Returns the user identifier to send with API requests
    /// Always uses deviceID as the stable unique identifier
    /// customID and email are sent as additional metadata to complement the device identity
    var userIdentifier: String {
        deviceID
    }
}
