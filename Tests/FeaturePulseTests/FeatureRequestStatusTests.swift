// swiftlint:disable identifier_name
@testable import FeaturePulse
import Testing

@Suite(.serialized, .tags(.models))
struct FeatureRequestStatusTests {
    @Test
    func `default system images`() {
        FeaturePulse.shared.statusConfig = nil

        #expect(FeatureRequestStatus.pending.systemImage == "hourglass.bottomhalf.filled")
        #expect(FeatureRequestStatus.approved.systemImage == "checkmark.seal.fill")
        #expect(FeatureRequestStatus.planned.systemImage == "calendar")
        #expect(FeatureRequestStatus.inProgress.systemImage == "clock.fill")
        #expect(FeatureRequestStatus.completed.systemImage == "checkmark.circle.fill")
        #expect(FeatureRequestStatus.rejected.systemImage == "xmark.circle.fill")
    }

    @Test
    func `status config overrides system image`() {
        FeaturePulse.shared.statusConfig = [
            "planned": StatusAppearance(color: "#123456", icon: "sparkles")
        ]
        defer { FeaturePulse.shared.statusConfig = nil }

        #expect(FeatureRequestStatus.planned.systemImage == "sparkles")
        #expect(FeatureRequestStatus.completed.systemImage == "checkmark.circle.fill")
    }

    @Test
    func `localized strings are available`() {
        for status in FeatureRequestStatus.allCases {
            #expect(!status.localizedString.isEmpty)
        }
    }
}

// swiftlint:enable identifier_name
