import SwiftUI

struct FeaturePulseEmptyStateView: View {
    let selectedTab: FeaturePulseView.FeatureTab
    let onRequestFeature: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: selectedTab == .completed ? "checkmark.circle" : "lightbulb.fill")
                .font(.system(size: 64))
                .foregroundStyle(FeaturePulse.shared.primaryColor)
                .backport.symbolEffect(.pulse)

            VStack(spacing: 8) {
                Text(selectedTab == .completed ? L10n.emptyStateCompletedTitle : L10n.emptyStateTitle)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(selectedTab == .completed ? L10n.emptyStateCompletedMessage : L10n.emptyStateMessage)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)

            if selectedTab == .requests {
                Button(action: onRequestFeature) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.body.weight(.semibold))
                        Text(L10n.requestFeature)
                            .font(.body.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.label)
                    .foregroundStyle(Color.systemBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .padding(.top, 12)
            }
        }
        .padding(.horizontal, 40)
    }
}
