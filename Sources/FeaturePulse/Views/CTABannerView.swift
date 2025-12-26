import SwiftUI

/// A dismissible banner view that encourages users to share feedback
///
/// Shows once until dismissed, then never appears again (stored in UserDefaults)
struct CTABannerView: View {
    let icon: String
    let text: String
    let onDismiss: () -> Void

    init(icon: String, text: String? = nil, onDismiss: @escaping () -> Void) {
        self.icon = icon
        self.text = text ?? L10n.ctaBannerMessage
        self.onDismiss = onDismiss
    }

    @State private var isVisible = false
    @State private var showFeaturePulse = false

    var body: some View {
        Button {
            // Dismiss banner with animation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isVisible = false
            }

            // Haptic feedback
            #if os(iOS)
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            #endif

            // Show FeaturePulse
            showFeaturePulse = true

            // Dismiss permanently after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onDismiss()
            }
        } label: {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(FeaturePulse.shared.foregroundColor)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(FeaturePulse.shared.foregroundColor.opacity(0.1))
                    )
                    .rotationEffect(.degrees(5))

                // Text
                Text(text)
                    .font(.headline)
                    .foregroundStyle(FeaturePulse.shared.foregroundColor)
                    .multilineTextAlignment(.leading)

                Spacer()

                // Close button
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isVisible = false
                    }

                    // Haptic feedback
                    #if os(iOS)
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    #endif

                    // Delay dismiss to allow animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onDismiss()
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(FeaturePulse.shared.foregroundColor.opacity(0.8))
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                // Gradient background
                LinearGradient(
                    colors: [
                        FeaturePulse.shared.primaryColor.opacity(0.5),
                        FeaturePulse.shared.primaryColor
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: FeaturePulse.shared.primaryColor.opacity(0.3), radius: 12, y: 4)
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
        .offset(y: isVisible ? 0 : -100)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3)) {
                isVisible = true
            }
        }
        .sheet(isPresented: $showFeaturePulse) {
            NavigationStack {
                FeaturePulse.shared.view()
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                showFeaturePulse = false
                            } label: {
                                Label("Close", systemImage: "xmark")
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    VStack {
        CTABannerView(
            icon: "lightbulb.fill",
            text: "Share your feedback!",
            onDismiss: {}
        )

        Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemGroupedBackground))
}
