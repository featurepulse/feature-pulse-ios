// swiftlint:disable identifier_name
@testable import FeaturePulse
import Foundation
import Testing

@Suite(.tags(.errors))
struct FeaturePulseErrorTests {
    @Test
    func `descriptions and recovery suggestions`() {
        #expect(
            FeaturePulseError.missingAPIKey.errorDescription ==
                "API key is required. Configure it via FeaturePulse.shared.apiKey"
        )
        #expect(
            FeaturePulseError.paymentRequired.recoverySuggestion ==
                "Upgrade your subscription to submit feature requests"
        )
        #expect(
            FeaturePulseError.serverError(500).recoverySuggestion ==
                "The server is experiencing issues. Please try again later"
        )
    }

    @Test
    func `retryable errors`() {
        #expect(FeaturePulseError.serverError(500).isRetryable)
        #expect(FeaturePulseError.invalidResponse.isRetryable)
        #expect(!FeaturePulseError.serverError(400).isRetryable)
        #expect(!FeaturePulseError.alreadyVoted.isRetryable)
    }

    @Test
    func `equatable network error uses localized description`() {
        let lhs = FeaturePulseError.networkError(URLError(.notConnectedToInternet))
        let rhs = FeaturePulseError.networkError(URLError(.notConnectedToInternet))

        #expect(lhs == rhs)
        #expect(lhs != FeaturePulseError.networkError(URLError(.timedOut)))
    }
}

// swiftlint:enable identifier_name
