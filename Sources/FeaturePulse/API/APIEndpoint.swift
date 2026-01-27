import Foundation

/// Type-safe API endpoint definitions
enum APIEndpoint {
    case activity
    case featureRequests
    case submitFeatureRequest
    case vote(featureRequestID: String)
    case unvote(featureRequestID: String)
    case syncUser

    /// HTTP method for this endpoint
    var method: HTTPMethod {
        switch self {
        case .featureRequests:
            .get
        case .activity, .submitFeatureRequest, .vote, .syncUser:
            .post
        case .unvote:
            .delete
        }
    }

    /// Path component for this endpoint
    var path: String {
        switch self {
        case .activity:
            "/api/sdk/activity"
        case .featureRequests, .submitFeatureRequest:
            "/api/sdk/feature-requests"
        case let .vote(id), let .unvote(id):
            "/api/sdk/feature-requests/\(id)/vote"
        case .syncUser:
            "/api/sdk/user"
        }
    }

    /// Build full URL with optional query parameters
    func url(baseURL: String, queryItems: [URLQueryItem]? = nil) -> URL? {
        var components = URLComponents(string: baseURL + path)
        if let queryItems, !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        return components?.url
    }
}

/// HTTP methods supported by the API
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}
