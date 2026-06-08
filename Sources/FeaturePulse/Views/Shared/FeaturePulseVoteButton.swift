import SwiftUI

struct FeaturePulseVoteButton: View {
    let voteCount: Int
    let hasVoted: Bool
    let voteTrigger: Int
    let isExternallyLoading: Bool
    let onVote: () async -> Bool
    let onVoteAnimationCompleted: (() async -> Void)?

    @State private var isVoting = false
    @State private var justVoted = false
    @State private var isPressing = false

    init(
        voteCount: Int,
        hasVoted: Bool,
        voteTrigger: Int = 0,
        isExternallyLoading: Bool = false,
        onVote: @escaping () async -> Bool,
        onVoteAnimationCompleted: (() async -> Void)? = nil
    ) {
        self.voteCount = voteCount
        self.hasVoted = hasVoted
        self.voteTrigger = voteTrigger
        self.isExternallyLoading = isExternallyLoading
        self.onVote = onVote
        self.onVoteAnimationCompleted = onVoteAnimationCompleted
    }

    var body: some View {
        Button {
            Task {
                await performVote()
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    Image(systemName: "triangle.fill")
                        .font(.caption2.weight(.semibold))
                        .opacity(isLoading ? 0 : 1)
                        .backport.symbolEffect(.bounce, value: justVoted)
                        .scaleEffect(isPressing ? 1.2 : 1)

                    ProgressView()
                        .controlSize(.small)
                        .tint(hasVoted ? FeaturePulse.shared.foregroundColor : voteColor)
                        .opacity(isLoading ? 1 : 0)
                }
                Text(verbatim: "\(voteCount)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .backport.contentTransition(.numericText(value: Double(voteCount)))
            }
            .frame(width: 56, height: 60)
        }
        .buttonStyle(FeaturePulseVoteButtonStyle(
            isVoted: hasVoted,
            isVoting: isLoading,
            isPressing: isPressing,
            voteColor: voteColor
        ))
        .disabled(isLoading)
        .accessibilityLabel(hasVoted ? L10n.removeVote : L10n.vote)
        .accessibilityValue(Text(verbatim: "\(voteCount)"))
        .onChangeBackport(of: voteTrigger) { _ in
            Task {
                await performVote()
            }
        }
    }

    private var voteColor: Color {
        FeaturePulse.shared.primaryColor
    }

    private var isLoading: Bool {
        isVoting || isExternallyLoading
    }

    @MainActor
    private func performVote() async {
        guard !isVoting else { return }

        await animateVotePress()

        isVoting = true
        let success = await onVote()
        isVoting = false

        if success {
            justVoted.toggle()
            try? await Task.sleep(for: .milliseconds(450))
            await onVoteAnimationCompleted?()
        }
    }

    @MainActor
    private func animateVotePress() async {
        withBackportAnimation(.smooth(duration: 0.12)) {
            isPressing = true
        }

        try? await Task.sleep(for: .milliseconds(120))

        withBackportAnimation(.bouncy(duration: 0.35)) {
            isPressing = false
        }
    }
}

private struct FeaturePulseVoteButtonStyle: ButtonStyle {
    let isVoted: Bool
    let isVoting: Bool
    let isPressing: Bool
    let voteColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(isVoted ? voteColor : voteColor.opacity(0.1))
            .foregroundStyle(isVoted ? FeaturePulse.shared.foregroundColor : voteColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isVoted ? Color.clear : voteColor.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed || isPressing ? 0.9 : 1)
            .opacity(isVoting ? 0.6 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.7), value: configuration.isPressed)
            .animation(.spring(response: 0.22, dampingFraction: 0.7), value: isPressing)
    }
}
