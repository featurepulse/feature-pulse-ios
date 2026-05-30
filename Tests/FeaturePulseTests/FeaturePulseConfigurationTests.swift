@testable import FeaturePulse
import Foundation
import Testing

@Suite(.serialized)
final class FeaturePulseConfigurationTests {
    deinit {
        resetSharedConfiguration()
    }

    @Test
    func `isConfigured reflects API key availability`() {
        #expect(!FeaturePulse.apiKeyIsConfigured(""))
        #expect(!FeaturePulse.apiKeyIsConfigured("   "))
        #expect(FeaturePulse.apiKeyIsConfigured("test-api-key"))
    }

    @Test
    func `localization overrides replace default strings`() {
        FeaturePulse.shared.localization = .init(
            featureRequests: "Feedback",
            restrictionMessage: "Nur {subscriptionName} Nutzer koennen neue Ideen anlegen."
        )

        #expect(L10n.featureRequests == "Feedback")
        #expect(L10n.restrictionMessage(subscriptionName: "Pro") == "Nur Pro Nutzer koennen neue Ideen anlegen.")
    }

    @Test
    func `localization supports direct typed mutation`() {
        FeaturePulse.shared.localization.requestFeature = "Idee senden"

        #expect(L10n.requestFeature == "Idee senden")
    }

    private func resetSharedConfiguration() {
        FeaturePulse.shared.apiKey = ""
        FeaturePulse.shared.localization = .init()
    }
}
