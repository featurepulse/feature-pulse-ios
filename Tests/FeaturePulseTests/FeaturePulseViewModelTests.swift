// swiftlint:disable identifier_name
@testable import FeaturePulse
import Testing

@Suite(.tags(.viewModels))
struct FeaturePulseViewModelTests {
    @Test
    func `preloaded requests seed voted IDs`() {
        let voted = FeatureRequest(
            id: "request-1",
            title: "Dark mode",
            description: "Add dark mode.",
            status: .planned,
            voteCount: 12,
            hasVoted: true
        )
        let notVoted = FeatureRequest(
            id: "request-2",
            title: "CSV export",
            description: "Export feedback.",
            status: .pending,
            voteCount: 4,
            hasVoted: false
        )

        let viewModel = FeaturePulseViewModel(preloaded: [voted, notVoted])

        #expect(viewModel.featureRequests == [voted, notVoted])
        #expect(viewModel.hasVoted(for: "request-1"))
        #expect(!viewModel.hasVoted(for: "request-2"))
        #expect(!viewModel.hasVoted(for: "missing"))
    }

    @Test
    func `default state is empty`() {
        let viewModel = FeaturePulseViewModel()

        #expect(viewModel.featureRequests.isEmpty)
        #expect(!viewModel.isLoading)
        #expect(viewModel.error == nil)
        #expect(viewModel.votedRequestIds.isEmpty)
        #expect(viewModel.voteErrorMessage == nil)
        #expect(!viewModel.showVoteError)
        #expect(viewModel.previousRequestCount == 0)
    }
}

// swiftlint:enable identifier_name
