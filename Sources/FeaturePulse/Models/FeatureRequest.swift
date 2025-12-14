import SwiftUI

/// Represents a feature request from a user
public struct FeatureRequest: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let description: String
    @Default<FirstCase> public var status: FeatureRequestStatus
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
        self._status = Default(wrappedValue: status)
        self.voteCount = voteCount
        self.hasVoted = hasVoted
    }

    // MARK: - Equatable
    public static func == (lhs: FeatureRequest, rhs: FeatureRequest) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.description == rhs.description &&
        lhs.status == rhs.status &&
        lhs.voteCount == rhs.voteCount &&
        lhs.hasVoted == rhs.hasVoted
    }

    // MARK: - Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(description)
        hasher.combine(status)
        hasher.combine(voteCount)
        hasher.combine(hasVoted)
    }
}
