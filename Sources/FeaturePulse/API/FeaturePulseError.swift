import Foundation

/// Errors that can occur when interacting with the FeaturePulse API
public enum FeaturePulseError: LocalizedError, Equatable {
    /// API key is missing or empty
    case missingAPIKey
    /// The constructed URL is invalid
    case invalidURL
    /// The server returned an invalid response
    case invalidResponse
    /// Server returned an error status code
    case serverError(Int)
    /// Failed to decode the response body
    case decodingError
    /// User has already voted for this feature request
    case alreadyVoted
    /// User doesn't have permission to create feature requests (subscription required)
    case paymentRequired
    /// Network connectivity issue
    case networkError(Error)

    public var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            "API key is required. Configure it via FeaturePulse.shared.apiKey"
        case .invalidURL:
            "Failed to construct a valid URL"
        case .invalidResponse:
            "Received an invalid response from the server"
        case let .serverError(code):
            "Server returned error code \(code)"
        case .decodingError:
            "Failed to decode the server response"
        case .alreadyVoted:
            "You have already voted for this feature request"
        case .paymentRequired:
            "A subscription is required to create feature requests"
        case let .networkError(error):
            "Network error: \(error.localizedDescription)"
        }
    }

    /// User-friendly recovery suggestion
    public var recoverySuggestion: String? {
        switch self {
        case .missingAPIKey:
            "Set your API key in your app's initialization code"
        case .invalidURL:
            "Check that the base URL is correctly configured"
        case .invalidResponse, .decodingError:
            "Try again later or contact support if the issue persists"
        case let .serverError(code) where code >= 500:
            "The server is experiencing issues. Please try again later"
        case .serverError:
            "Check your request and try again"
        case .alreadyVoted:
            "You can only vote once per feature request"
        case .paymentRequired:
            "Upgrade your subscription to submit feature requests"
        case .networkError:
            "Check your internet connection and try again"
        }
    }

    /// Whether this error is recoverable by retrying
    public var isRetryable: Bool {
        switch self {
        case let .serverError(code) where code >= 500:
            true
        case .networkError:
            true
        case .invalidResponse:
            true
        default:
            false
        }
    }

    // MARK: - Equatable
    public static func == (lhs: FeaturePulseError, rhs: FeaturePulseError) -> Bool {
        switch (lhs, rhs) {
        case (.missingAPIKey, .missingAPIKey),
             (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.decodingError, .decodingError),
             (.alreadyVoted, .alreadyVoted),
             (.paymentRequired, .paymentRequired):
            true
        case let (.serverError(lhsCode), .serverError(rhsCode)):
            lhsCode == rhsCode
        case let (.networkError(lhsError), .networkError(rhsError)):
            lhsError.localizedDescription == rhsError.localizedDescription
        default:
            false
        }
    }
}
