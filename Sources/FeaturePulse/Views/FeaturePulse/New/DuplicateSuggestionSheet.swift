import SwiftUI

struct DuplicateSuggestionSheet: View {
    @Environment(\.dismiss) private var dismiss

    let suggestion: DuplicateSuggestion
    let submitAnyway: () -> Void
    let voteForExisting: () async -> Bool
    let onVoteAnimationCompleted: () -> Void

    @State private var isVoting = false
    @State private var isCompletingVote = false
    @State private var displayedHasVoted = false
    @State private var displayedVoteCount: Int
    @State private var voteTrigger = 0

    init(
        suggestion: DuplicateSuggestion,
        submitAnyway: @escaping () -> Void,
        voteForExisting: @escaping () async -> Bool,
        onVoteAnimationCompleted: @escaping () -> Void
    ) {
        self.suggestion = suggestion
        self.submitAnyway = submitAnyway
        self.voteForExisting = voteForExisting
        self.onVoteAnimationCompleted = onVoteAnimationCompleted
        _displayedVoteCount = State(initialValue: suggestion.request.voteCount)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                Text(L10n.duplicateSuggestionMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                suggestedRequestRow
                actionButtons
            }
            .padding(20)
            .navigationTitle(L10n.duplicateSuggestionTitle)
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                .presentationDetents([.height(420), .large])
                .presentationDragIndicator(.visible)
            #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        closeButton
                    }
                }
        }
    }

    private var suggestedRequestRow: some View {
        FeatureRequestRow(
            request: displayedRequest,
            hasVoted: displayedHasVoted,
            translatedTitle: nil,
            translatedDescription: nil,
            usesScrollTransition: false,
            contentPadding: EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12),
            backgroundStyle: .subtle,
            voteTrigger: voteTrigger,
            isVoteLoading: isVoting,
            onSelect: {},
            onVote: voteForSuggestedRequest,
            onVoteAnimationCompleted: completeVoteFlow
        )
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            voteButton
            submitAnywayButton
        }
    }

    private var displayedRequest: FeatureRequest {
        FeatureRequest(
            id: suggestion.request.id,
            title: suggestion.request.title,
            description: suggestion.request.description,
            status: suggestion.request.status,
            voteCount: displayedVoteCount,
            hasVoted: displayedHasVoted,
            isOwner: suggestion.request.isOwner,
            createdAt: suggestion.request.createdAt
        )
    }

    private var voteButton: some View {
        Button {
            guard !isVoting, !isCompletingVote else { return }
            withBackportAnimation(.smooth(duration: 0.2)) {
                voteTrigger += 1
            }
        } label: {
            HStack(spacing: 8) {
                if isVoting {
                    ProgressView()
                        .controlSize(.small)
                        .tint(FeaturePulse.shared.foregroundColor)
                } else {
                    Image(systemName: "triangle.fill")
                        .font(.caption.weight(.semibold))
                }
                Text(L10n.voteForExisting)
            }
            .font(.body.weight(.semibold))
            .frame(minHeight: 32)
            .frame(maxWidth: .infinity)
        }
        .primaryGlassEffect()
        .tint(FeaturePulse.shared.primaryColor)
        .foregroundStyle(FeaturePulse.shared.foregroundColor)
        .opacity(isVoting ? 0.75 : 1)
        .disabled(isVoting || isCompletingVote)
    }

    private var submitAnywayButton: some View {
        Button {
            dismiss()
            submitAnyway()
        } label: {
            Text(L10n.submitAnyway)
                .font(.body.weight(.semibold))
                .frame(minHeight: 32)
                .frame(maxWidth: .infinity)
        }
        .primaryGlassEffect()
        .tint(Color.label)
        .foregroundStyle(Color.systemBackground)
        .opacity(isVoting ? 0.45 : 1)
        .disabled(isVoting || isCompletingVote)
    }

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.body.weight(.semibold))
        }
        .accessibilityLabel(L10n.close)
        .disabled(isVoting || isCompletingVote)
    }

    private func voteForSuggestedRequest() async -> Bool {
        guard !isVoting, !isCompletingVote else { return false }
        isVoting = true
        let success = await voteForExisting()
        if success {
            withBackportAnimation(.bouncy(duration: 0.35)) {
                isVoting = false
                isCompletingVote = true
                if !displayedHasVoted {
                    displayedHasVoted = true
                    if !suggestion.request.hasVoted {
                        displayedVoteCount += 1
                    }
                }
            }
        } else {
            isVoting = false
        }
        return success
    }

    @MainActor
    private func completeVoteFlow() {
        dismiss()
        onVoteAnimationCompleted()
    }
}
