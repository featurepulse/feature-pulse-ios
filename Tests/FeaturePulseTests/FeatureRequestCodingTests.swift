// swiftlint:disable identifier_name
@testable import FeaturePulse
import Foundation
import Testing

@Suite(.tags(.models))
struct FeatureRequestCodingTests {
    @Test
    func `decodes snake case fields`() throws {
        let data = """
        {
          "id": "fr_1",
          "title": "Dark mode",
          "description": "Add a dark theme.",
          "status": "in_progress",
          "vote_count": 42,
          "has_voted": true,
          "is_owner": true,
          "created_at": "2026-05-26T10:00:00Z"
        }
        """.data(using: .utf8)!

        let request = try JSONDecoder().decode(FeatureRequest.self, from: data)

        #expect(request.id == "fr_1")
        #expect(request.title == "Dark mode")
        #expect(request.description == "Add a dark theme.")
        #expect(request.status == .inProgress)
        #expect(request.voteCount == 42)
        #expect(request.hasVoted)
        #expect(request.isOwner)
        #expect(request.createdAt == "2026-05-26T10:00:00Z")
    }

    @Test
    func `unknown status falls back to first case`() throws {
        let data = """
        {
          "id": "fr_2",
          "title": "Widgets",
          "description": "Add widgets.",
          "status": "shipped-ish",
          "vote_count": 7,
          "has_voted": false,
          "is_owner": false
        }
        """.data(using: .utf8)!

        let request = try JSONDecoder().decode(FeatureRequest.self, from: data)

        #expect(request.status == .pending)
    }

    @Test
    func `hashable and equality ignore created at`() {
        let lhs = FeatureRequest(
            id: "fr_3",
            title: "Export",
            description: "CSV export",
            status: .planned,
            voteCount: 3,
            hasVoted: false,
            isOwner: false,
            createdAt: "2026-05-26T10:00:00Z"
        )
        let rhs = FeatureRequest(
            id: "fr_3",
            title: "Export",
            description: "CSV export",
            status: .planned,
            voteCount: 3,
            hasVoted: false,
            isOwner: false,
            createdAt: "2026-05-27T10:00:00Z"
        )

        #expect(lhs == rhs)
        #expect(Set([lhs, rhs]).count == 1)
    }
}

// swiftlint:enable identifier_name
