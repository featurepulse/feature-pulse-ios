import SwiftUI

struct FeaturePulseListFooter: View {
    let showWatermark: Bool
    let onRequestFeature: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.ctaMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)

                Button(action: onRequestFeature) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.body.weight(.semibold))
                        Text(L10n.requestFeature)
                            .font(.body.weight(.semibold))
                    }
                    .frame(minHeight: 32)
                    .frame(maxWidth: .infinity)
                }
                .primaryGlassEffect()
                .tint(Color.label)
                .foregroundStyle(Color.systemBackground)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 32)

            if showWatermark {
                HStack(spacing: 6) {
                    Text(L10n.poweredBy)
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                    Image("Logo", bundle: .module)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                }
                .padding(.bottom, 24)
                .unredacted()
            }
        }
    }
}
