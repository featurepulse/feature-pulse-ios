import SwiftUI

struct FeaturePulseThankYouToast: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
            Text(L10n.thankYou)
                .font(.subheadline.weight(.medium))
        }
        .foregroundStyle(Color.systemBackground)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.label, in: Capsule())
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        .padding(.top, 8)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
