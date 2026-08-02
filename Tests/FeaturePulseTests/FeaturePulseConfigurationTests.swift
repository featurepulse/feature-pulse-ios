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
            restrictionMessage: "Nur {subscriptionName} Nutzer koennen neue Ideen anlegen.",
            vote: "Stimme geben",
            removeVote: "Stimme entfernen"
        )

        #expect(L10n.featureRequests == "Feedback")
        #expect(L10n.vote == "Stimme geben")
        #expect(L10n.removeVote == "Stimme entfernen")
        #expect(L10n.restrictionMessage(subscriptionName: "Pro") == "Nur Pro Nutzer koennen neue Ideen anlegen.")
    }

    @Test
    func `restriction message supports printf placeholder`() {
        FeaturePulse.shared.localization.restrictionMessage = "Only %@ users can add new requests."

        #expect(L10n.restrictionMessage(subscriptionName: "Premium") == "Only Premium users can add new requests.")
    }

    @Test
    func `localization supports direct typed mutation`() {
        FeaturePulse.shared.localization.requestFeature = "Idee senden"

        #expect(L10n.requestFeature == "Idee senden")
    }

    @Test
    func `duplicate suggestion strings are localized for supported languages`() throws {
        let supportedLanguages = ["de", "en", "es", "fr", "it", "pt-PT", "zh-Hans"]
        let requiredKeys = [
            "Close",
            "duplicate.suggestion.title",
            "duplicate.suggestion.message",
            "duplicate.suggestion.voteForExisting",
            "duplicate.suggestion.submitAnyway"
        ]

        let fileURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appending(path: "Sources/FeaturePulse/Resources/Localizable.xcstrings")
        let data = try Data(contentsOf: fileURL)
        let catalog = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let strings = try #require(catalog["strings"] as? [String: Any])

        for key in requiredKeys {
            let entry = try #require(strings[key] as? [String: Any], "Missing localization key: \(key)")
            let localizations = try #require(entry["localizations"] as? [String: Any], "Missing localizations for \(key)")

            for language in supportedLanguages {
                let localization = try #require(
                    localizations[language] as? [String: Any],
                    "Missing \(language) localization for \(key)"
                )
                let stringUnit = try #require(
                    localization["stringUnit"] as? [String: Any],
                    "Missing string unit for \(key) in \(language)"
                )
                let value = try #require(
                    stringUnit["value"] as? String,
                    "Missing localized value for \(key) in \(language)"
                )

                #expect(!value.isEmpty, "Empty localized value for \(key) in \(language)")
            }
        }
    }

    private func resetSharedConfiguration() {
        FeaturePulse.shared.apiKey = ""
        FeaturePulse.shared.localization = .init()
    }
}
