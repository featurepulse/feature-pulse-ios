// swiftlint:disable identifier_name
@testable import FeaturePulse
import Foundation
import Testing

@Suite(.serialized, .tags(.storage))
final class UserDefaultsManagerTests {
    init() {
        resetFeaturePulseDefaults()
    }

    deinit {
        resetFeaturePulseDefaults()
    }

    @Test
    func `stores session state`() {
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
        UserDefaultsManager.ctaBannerDismissed = true

        UserDefaultsManager.ctaBannerDismissed = false

        #expect(!UserDefaultsManager.ctaBannerDismissed)
    }

    private func resetFeaturePulseDefaults() {
        [
            "se.featurepul.deviceID",
            "se.featurepul.lastSessionTime",
            "se.featurepul.sessionCount",
            "se.featurepul.ctaDismissed",
            "se.featurepul.lastSyncedCustomID",
            "se.featurepul.lastSyncedPayment",
            "se.featurepul.isUserActive"
        ].forEach(UserDefaults.standard.removeObject)
    }
}

// swiftlint:enable identifier_name
