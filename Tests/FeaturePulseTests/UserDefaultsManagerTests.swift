// swiftlint:disable identifier_name
@testable import FeaturePulse
import Foundation
import Testing

@Suite(.serialized, .tags(.storage))
final class UserDefaultsManagerTests {
    deinit {
        resetFeaturePulseDefaults()
    }

    @Test
    func `stores session state`() {
        resetFeaturePulseDefaults()

        UserDefaultsManager.lastSessionTime = 123.5
        UserDefaultsManager.sessionCount = 4
        UserDefaultsManager.ctaBannerDismissed = true
        UserDefaultsManager.isUserActive = true

        #expect(UserDefaultsManager.lastSessionTime == 123.5)
        #expect(UserDefaultsManager.sessionCount == 4)
        #expect(UserDefaultsManager.ctaBannerDismissed)
        #expect(UserDefaultsManager.isUserActive)
    }

    @Test
    func `stores synced user cache`() {
        resetFeaturePulseDefaults()

        let payment = FeaturePulse.Payment.yearly(79.99, currency: "USD")

        UserDefaultsManager.lastSyncedCustomID = "user-1"
        UserDefaultsManager.lastSyncedPayment = payment

        #expect(UserDefaultsManager.lastSyncedCustomID == "user-1")
        #expect(UserDefaultsManager.lastSyncedPayment == payment)

        UserDefaultsManager.lastSyncedPayment = nil
        #expect(UserDefaultsManager.lastSyncedPayment == nil)
    }

    @Test
    func `clears CTA banner dismissal`() {
        resetFeaturePulseDefaults()

        UserDefaultsManager.ctaBannerDismissed = true

        UserDefaultsManager.ctaBannerDismissed = false

        #expect(!UserDefaultsManager.ctaBannerDismissed)
    }

    @Test
    func `user creates and reuses local device ID`() throws {
        resetFeaturePulseDefaults()

        let firstUser = User()
        let firstID = firstUser.deviceID

        #expect(!firstID.isEmpty)
        #expect(UUID(uuidString: firstID) != nil)
        #expect(UserDefaultsManager.deviceID == firstID)

        let secondUser = User()
        #expect(secondUser.deviceID == firstID)
    }

    @Test
    func `user identifier prefers custom ID`() throws {
        resetFeaturePulseDefaults()

        let user = User()
        let deviceID = user.deviceID

        #expect(user.userIdentifier == deviceID)

        user.customID = "account-1"

        #expect(user.userIdentifier == "account-1")
    }

    @Test
    func `user migrates legacy StableID device ID`() throws {
        resetFeaturePulseDefaults()

        let legacyID = "legacy-stable-id"
        UserDefaults(suiteName: "_StableID_DefaultsSuiteName")?.set(legacyID, forKey: "_StableID_Identifier")

        let user = User()

        #expect(user.deviceID == legacyID)
        #expect(UserDefaultsManager.deviceID == legacyID)
        #expect(DeviceIDMigration.isCompleted)
    }

    @Test
    func `user migrates legacy StableID before trusting generated FeaturePulse ID`() throws {
        resetFeaturePulseDefaults()

        let legacyID = "legacy-stable-id"
        UserDefaultsManager.deviceID = "generated-before-migration"
        UserDefaults(suiteName: "_StableID_DefaultsSuiteName")?.set(legacyID, forKey: "_StableID_Identifier")

        let user = User()

        #expect(user.deviceID == legacyID)
        #expect(UserDefaultsManager.deviceID == legacyID)
        #expect(DeviceIDMigration.isCompleted)
    }

    @Test
    func `user migrates legacy standard FeaturePulse device ID before generated ID`() throws {
        resetFeaturePulseDefaults()

        let legacyID = "legacy-standard-featurepulse-id"
        UserDefaultsManager.deviceID = "generated-before-migration"
        UserDefaults.standard.set(legacyID, forKey: "se.featurepul.deviceID")

        let user = User()

        #expect(user.deviceID == legacyID)
        #expect(UserDefaultsManager.deviceID == legacyID)
        #expect(DeviceIDMigration.isCompleted)
    }

    private func resetFeaturePulseDefaults() {
        [
            "se.featurepul.deviceID",
            "se.featurepul.legacyDeviceIDMigrationCompleted",
            "se.featurepul.lastSessionTime",
            "se.featurepul.sessionCount",
            "se.featurepul.ctaDismissed",
            "se.featurepul.lastSyncedCustomID",
            "se.featurepul.lastSyncedPayment",
            "se.featurepul.isUserActive"
        ].forEach(UserDefaults.standard.removeObject)
        [
            "se.featurepul.deviceID",
            "se.featurepul.lastSessionTime",
            "se.featurepul.sessionCount",
            "se.featurepul.ctaDismissed",
            "se.featurepul.lastSyncedCustomID",
            "se.featurepul.lastSyncedPayment",
            "se.featurepul.isUserActive"
        ].forEach(UserDefaultsManager.removeObject)
        DeviceIDMigration.resetForTests()
    }
}

// swiftlint:enable identifier_name
