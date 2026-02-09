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

    /// Serial queue to ensure thread-safe StableID configuration
    private static let configurationQueue = DispatchQueue(label: "se.featurepul.stableid.config")

    /// Flag to track if StableID has been configured by this SDK
    nonisolated(unsafe) private static var hasConfiguredStableID = false

    init() {
        // Use StableID for persistent device identification
        // Syncs across devices via App Store Transaction ID (iOS 16+) or iCloud

        #if targetEnvironment(simulator)
            // For simulator, generate a stable UUID stored in UserDefaults
            deviceID = Self.getOrCreateSimulatorID()
        #else
            // For real devices, use StableID
            // Initial sync: use cached ID if available, configure async for App Store ID
            deviceID = Self.configureAndGetStableID()
            Self.configureWithAppTransactionIDIfNeeded()
        #endif
    }

    /// Returns the user identifier to send with API requests
    /// Always uses deviceID as the stable unique identifier
    /// customID and email are sent as additional metadata to complement the device identity
    var userIdentifier: String {
        deviceID
    }

    // MARK: - Private Helpers

    /// Thread-safe StableID configuration and retrieval
    private static func configureAndGetStableID() -> String {
        configurationQueue.sync {
            // Check if already configured (by us or externally)
            if !hasConfiguredStableID && !StableID.isConfigured {
                // Use .preferStored policy to respect any existing ID
                if StableID.hasStoredID {
                    StableID.configure()
                } else {
                    // No stored ID - configure with default generator for now
                    // App Transaction ID will be fetched async below
                    StableID.configure()
                }
                hasConfiguredStableID = true
            }

            // Get the ID, with fallback to UserDefaults if StableID fails
            let stableID = StableID.id
            if !stableID.isEmpty {
                // Cache in UserDefaults as backup
                UserDefaultsManager.deviceID = stableID
                return stableID
            }

            // Fallback: Use cached ID from UserDefaults
            if let cachedID = UserDefaultsManager.deviceID {
                return cachedID
            }

            // Last resort: Generate new UUID and store it
            let newID = UUID().uuidString
            UserDefaultsManager.deviceID = newID
            return newID
        }
    }

    /// Async configuration with App Store Transaction ID (iOS 16+)
    /// This provides a stable ID tied to the user's Apple Account - no iCloud capability needed
    private static func configureWithAppTransactionIDIfNeeded() {
        // Only fetch App Transaction ID if we don't have a stored ID yet
        guard !StableID.hasStoredID else { return }

        Task {
            do {
                // Fetch App Store Transaction ID (tied to Apple Account, syncs across devices)
                let appTransactionID = try await StableID.fetchAppTransactionID()
                // Configure with .preferStored to not override if another device already synced
                StableID.configure(id: appTransactionID, policy: .preferStored)
                // Update cached ID
                UserDefaultsManager.deviceID = StableID.id
            } catch {
                // App Transaction ID not available (e.g., not distributed via App Store)
                // StableID will use its default UUID-based approach
            }
        }
    }

    /// Get or create a simulator-specific device ID
    private static func getOrCreateSimulatorID() -> String {
        if let stored = UserDefaultsManager.deviceID {
            return stored
        }
        let newID = UUID().uuidString
        UserDefaultsManager.deviceID = newID
        return newID
    }
}
