import FeaturePulse
import SwiftUI

struct FeaturePulseEmbeddedView: View {
    let featurePulseViewID: UUID
    let locale: Locale
    var navigationTitle: String?
    var onClose: (() -> Void)?

    var body: some View {
        FeaturePulse.shared.view()
            .id(featurePulseViewID)
            .modifier(NavigationTitleModifier(title: navigationTitle))
            .toolbar {
                if let onClose {
                    ToolbarItem(placement: .topBarLeading) {
                        if #available(iOS 26, *) {
                            Button(role: .close, action: onClose)
                        } else {
                            Button(action: onClose) {
                                Label("Close", systemImage: "xmark")
                            }
                        }
                    }
                }
            }
    }
}

private struct NavigationTitleModifier: ViewModifier {
    let title: String?

    func body(content: Content) -> some View {
        if let title {
            content.navigationTitle(title)
        } else {
            content
        }
    }
}

#Preview {
    NavigationStack {
        FeaturePulseEmbeddedView(
            featurePulseViewID: UUID(),
            locale: .current,
            navigationTitle: "Feedback"
        )
    }
}
