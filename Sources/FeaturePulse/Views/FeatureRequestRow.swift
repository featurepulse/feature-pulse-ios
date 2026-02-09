import SwiftUI

/// Individual feature request row
struct FeatureRequestRow: View {
    // MARK: - Properties
    let request: FeatureRequest
    let hasVoted: Bool
    let translatedTitle: String?
    let translatedDescription: String?
    let onVote: () async -> Bool

    @State private var isVoting = false
    @State private var justVoted = false
    @State private var isPressing = false

    private var displayTitle: String {
        translatedTitle ?? request.title
    }

    private var displayDescription: String {
        translatedDescription ?? request.description
    }

    // MARK: - UI
    var body: some View {
        HStack(spacing: 12) {
            // Vote Button
            VStack(spacing: 4) {
                ZStack {
                    Image(systemName: "triangle.fill")
                        .font(.caption2.weight(.semibold))
                        .opacity(isVoting ? 0 : 1)
                        .symbolEffect(.bounce, value: justVoted)
                        .scaleEffect(isPressing ? 1.2 : 1)

                    ProgressView()
                        .controlSize(.small)
                        .tint(hasVoted ? FeaturePulse.shared.foregroundColor : voteColor)
                        .opacity(isVoting ? 1 : 0)
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
            .contentShape(Rectangle())
            .scaleEffect(isPressing ? 0.9 : 1)
            .opacity(isVoting ? 0.6 : 1.0)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard !isVoting else { return }
                        withAnimation(.smooth(duration: 0.2)) {
                            isPressing = true
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.bouncy(duration: 0.5)) {
                            isPressing = false
                        }
                        guard !isVoting else { return }
                        Task {
                            isVoting = true
                            let success = await onVote()
                            isVoting = false

                            if success {
                                justVoted.toggle()
                            }
                        }
                    }
            )

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
                // Hide "approved" badge for non-owners
                if FeaturePulse.shared.showStatus, !(request.status == .approved && !request.isOwner) {
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

// MARK: - Previews
#Preview("Default") {
    FeatureRequestRow(
        request: FeatureRequest(
            id: "1",
            title: "Dark Mode Support",
            description: "Add dark mode to make the app easier to use at night",
            status: .pending,
            voteCount: 42,
            hasVoted: false
        ),
        hasVoted: false,
        translatedTitle: nil,
        translatedDescription: nil,
        onVote: { true }
    )
    .padding()
}

#Preview("Voted") {
    FeatureRequestRow(
        request: FeatureRequest(
            id: "2",
            title: "Export to PDF",
            description: "Allow users to export their data as PDF documents for offline viewing",
            status: .inProgress,
            voteCount: 128,
            hasVoted: true
        ),
        hasVoted: true,
        translatedTitle: nil,
        translatedDescription: nil,
        onVote: { true }
    )
    .padding()
}
