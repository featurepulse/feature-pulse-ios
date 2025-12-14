import SwiftUI

/// Individual feature request row
struct FeatureRequestRow: View {
    let request: FeatureRequest
    let hasVoted: Bool
    let translatedTitle: String?
    let translatedDescription: String?
    let onVote: () async -> Bool

    @State private var isVoting = false
    @State private var justVoted = false
    @State private var scale: CGFloat = 1.0

    private var displayTitle: String {
        translatedTitle ?? request.title
    }

    private var displayDescription: String {
        translatedDescription ?? request.description
    }

    var body: some View {
        HStack(spacing: 12) {
            // Vote Button
            VStack(spacing: 4) {
                if isVoting {
                    ProgressView()
                        .controlSize(.small)
                        .tint(hasVoted ? FeaturePulse.shared.primaryColor : voteColor)
                } else {
                    Image(systemName: "triangle.fill")
                        .font(.caption2.weight(.semibold))
                        .symbolEffect(.bounce, value: justVoted)
                }
                Text("\(request.voteCount)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .contentTransition(.numericText(value: Double(request.voteCount)))
            }
            .frame(width: 56, height: 60)
            .background(hasVoted ? voteColor : voteColor.opacity(0.1))
            .foregroundStyle(
                hasVoted ? FeaturePulse.shared.foregroundColor : voteColor
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(hasVoted ? Color.clear : voteColor.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(scale)
            .contentShape(Rectangle())
            .disabled(isVoting)
            .opacity(isVoting ? 0.6 : 1.0)
            .onTapGesture {
                guard !isVoting else { return }
                Task {
                    isVoting = true
                    let success = await onVote()
                    isVoting = false

                    if success {
                        // Animate vote/unvote
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            scale = 1.2
                        }
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.1)) {
                            scale = 1.0
                        }
                        justVoted.toggle()
                    }
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(displayTitle)
                    .font(.headline)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(displayDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Show status badge only if enabled from dashboard
                if FeaturePulse.shared.showStatus {
                    HStack(spacing: 4) {
                        Image(systemName: request.status.systemImage)
                            .font(.system(size: 11, weight: .semibold))
                        Text(request.status.localizedString)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(request.status.color.opacity(0.15))
                    .foregroundStyle(request.status.color)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(request.status.color.opacity(0.3), lineWidth: 1.5)
                    )
                }
            }
        }
        .padding(.vertical, 8)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .scrollTransition(.animated.threshold(.visible(0.1))) { content, phase in
            content
                .opacity(phase.isIdentity ? 1 : 0.2)
                .scaleEffect(phase.isIdentity ? 1 : 0.9)
                .blur(radius: phase.isIdentity ? 0 : 10)
        }
    }

    private var voteColor: Color {
        FeaturePulse.shared.primaryColor
    }
}
