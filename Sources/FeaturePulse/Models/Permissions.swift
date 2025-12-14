import Foundation

/// Represents user permissions for feature requests
public struct Permissions: Codable, Hashable, Sendable {
    /// Whether the user can create new feature requests
    public let canCreateFeatureRequest: Bool

    enum CodingKeys: String, CodingKey {
        case canCreateFeatureRequest = "can_create_feature_request"
    }

    public init(canCreateFeatureRequest: Bool) {
        self.canCreateFeatureRequest = canCreateFeatureRequest
    }
}
