import SwiftUI

/// Individual feature request row
struct FeatureRequestRow: View {
    enum BackgroundStyle {
        case standard
        case subtle
    }

    // MARK: - Properties
    let request: FeatureRequest
    let hasVoted: Bool
    let translatedTitle: String?
    let translatedDescription: String?
    let usesScrollTransition: Bool
    let contentPadding: EdgeInsets
    let backgroundStyle: BackgroundStyle
    let voteTrigger: Int
    let isVoteLoading: Bool
    let onSelect: () -> Void
    let onVote: () async -> Bool

    init(
        request: FeatureRequest,
        hasVoted: Bool,
        translatedTitle: String?,
        translatedDescription: String?,
        usesScrollTransition: Bool = true,
        contentPadding: EdgeInsets = EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0),
        backgroundStyle: BackgroundStyle = .standard,
        voteTrigger: Int = 0,
        isVoteLoading: Bool = false,
        onSelect: @escaping () -> Void,
        onVote: @escaping () async -> Bool
    ) {
        self.request = request
        self.hasVoted = hasVoted
        self.translatedTitle = translatedTitle
        self.translatedDescription = translatedDescription
        self.usesScrollTransition = usesScrollTransition
        self.contentPadding = contentPadding
        self.backgroundStyle = backgroundStyle
        self.voteTrigger = voteTrigger
        self.isVoteLoading = isVoteLoading
        self.onSelect = onSelect
        self.onVote = onVote
    }

    private var displayTitle: String {
        translatedTitle ?? request.title
    }

    private var displayDescription: String {
        translatedDescription ?? request.description
    }

    // MARK: - UI
    var body: some View {
        HStack(spacing: 12) {
            voteButton

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
            .contentShape(Rectangle())
            .onTapGesture(perform: onSelect)
        }
        .padding(contentPadding)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(rowBackground)
        }
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .modifier(FeatureRequestRowScrollTransition(enabled: usesScrollTransition))
    }

    private var rowBackground: Color {
        switch backgroundStyle {
        case .standard:
            Color.systemBackground
        case .subtle:
            Color.secondary.opacity(0.12)
        }
    }

    private var voteButton: some View {
        FeaturePulseVoteButton(
            voteCount: request.voteCount,
            hasVoted: hasVoted,
            voteTrigger: voteTrigger,
            isExternallyLoading: isVoteLoading,
            onVote: onVote
        )
    }
}

private struct FeatureRequestRowScrollTransition: ViewModifier {
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.backport.scrollTransition()
        } else {
            content
        }
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
        onSelect: {},
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
        onSelect: {},
        onVote: { true }
    )
    .padding()
}
