import SwiftUI

/// Detail view showing full feature request information
struct FeatureRequestDetailView: View {
    @Binding var request: FeatureRequest
    let hasVoted: Bool
    let translatedTitle: String?
    let translatedDescription: String?
    let onVote: () async -> Bool
    @Environment(\.dismiss) private var dismiss

    @State private var isVoting = false
    @State private var localHasVoted: Bool

    private var displayTitle: String {
        translatedTitle ?? request.title
    }

    private var displayDescription: String {
        translatedDescription ?? request.description
    }

    init(request: Binding<FeatureRequest>, hasVoted: Bool, translatedTitle: String? = nil, translatedDescription: String? = nil, onVote: @escaping () async -> Bool) {
        _request = request
        self.hasVoted = hasVoted
        self.translatedTitle = translatedTitle
        self.translatedDescription = translatedDescription
        self.onVote = onVote
        _localHasVoted = State(initialValue: hasVoted)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if FeaturePulseConfiguration.shared.showStatus {
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

                    // Title
                    Text(displayTitle)
                        .font(.title2.bold())
                        .foregroundStyle(.primary)

                    // Description
                    Text(displayDescription)
                        .font(.body)
                        .foregroundStyle(.secondary)

                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle(L10n.featureRequests)
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        #if os(iOS)
                            if #available(iOS 26.0, *) {
                                Button(role: .close) {
                                    dismiss()
                                }
                            } else {
                                Button(L10n.cancel) {
                                    dismiss()
                                }
                            }
                        #else
                            Button(L10n.cancel) {
                                dismiss()
                            }
                        #endif
                    }

                    #if os(iOS)
                        if #available(iOS 26.0, *) {
                            vote.sharedBackgroundVisibility(.hidden)
                        } else {
                            vote
                        }
                    #else
                        vote
                    #endif
                }
        }
    }

    private var vote: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button {
                Task {
                    isVoting = true
                    let success = await onVote()
                    if success {
                        localHasVoted.toggle()
                    }
                    isVoting = false
                }
            } label: {
                HStack(spacing: 4) {
                    if isVoting {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "triangle.fill")
                            .font(.caption2.weight(.semibold))
                            .symbolEffect(.bounce, value: request.hasVoted)
                    }
                    Text("\(request.voteCount)")
                        .font(.subheadline.weight(.semibold))
                        .contentTransition(.numericText(value: Double(request.voteCount)))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(localHasVoted ? voteColor : voteColor.opacity(0.1))
                .foregroundStyle(localHasVoted ? FeaturePulseConfiguration.shared.foregroundColor : voteColor)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .disabled(isVoting)
        }
    }

    private var voteColor: Color {
        FeaturePulseConfiguration.shared.primaryColor
    }
}
