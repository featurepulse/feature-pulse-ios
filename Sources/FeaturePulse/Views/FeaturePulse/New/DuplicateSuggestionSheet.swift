import SwiftUI

struct DuplicateSuggestionSheet: View {
    @Environment(\.dismiss) private var dismiss

    let suggestion: DuplicateSuggestion
    let submitAnyway: () -> Void
    let voteForExisting: () async -> Bool

    @State private var isVoting = false
    @State private var voteTrigger = 0

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
            request: suggestion.request,
            hasVoted: false,
            translatedTitle: nil,
            translatedDescription: nil,
            usesScrollTransition: false,
            contentPadding: EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12),
            backgroundStyle: .subtle,
            voteTrigger: voteTrigger,
            isVoteLoading: isVoting,
            onSelect: {},
            onVote: voteForSuggestedRequest
        )
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            voteButton
            submitAnywayButton
        }
    }

    private var voteButton: some View {
        Button {
            guard !isVoting else { return }
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
        .disabled(isVoting)
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
        .disabled(isVoting)
    }

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.body.weight(.semibold))
        }
        .accessibilityLabel(L10n.close)
        .disabled(isVoting)
    }

    private func voteForSuggestedRequest() async -> Bool {
        guard !isVoting else { return false }
        isVoting = true
        let success = await voteForExisting()
        if !success {
            isVoting = false
        }
        return success
    }
}
