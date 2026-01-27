import Foundation

// MARK: - Generic Response Wrapper

/// Generic API response wrapper for simple responses
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T
}

// MARK: - Feature Requests

/// Response for fetching feature requests
struct FeatureRequestsResponse: Codable {
    let success: Bool
    let data: [FeatureRequest]
    let showStatus: Bool?
    let showTranslation: Bool?
    let showWatermark: Bool?
    let permissions: Permissions?

    enum CodingKeys: String, CodingKey {
        case success, data, permissions
        case showStatus = "show_status"
        case showTranslation = "show_translation"
        case showWatermark = "show_watermark"
    }
}

// MARK: - Activity

/// Response for activity tracking
struct ActivityResponse: Codable {
    let success: Bool
    let message: String?
}

// MARK: - Empty Response

/// Empty response for endpoints that don't return data
struct EmptyResponse: Codable {
    let success: Bool?
    let message: String?

    init() {
        success = true
        message = nil
    }
}
