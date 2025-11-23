import SwiftUI

/// Represents a feature request from a user
public struct FeatureRequest: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let description: String
    public let status: FeatureRequestStatus
    public let voteCount: Int
    public let hasVoted: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case status
        case voteCount = "vote_count"
        case hasVoted = "has_voted"
    }

    public init(
        id: String,
        title: String,
        description: String,
        status: FeatureRequestStatus,
        voteCount: Int,
        hasVoted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.status = status
        self.voteCount = voteCount
        self.hasVoted = hasVoted
    }
}
