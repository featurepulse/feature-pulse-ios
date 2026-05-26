import FeaturePulse
import SwiftUI

struct DemoHomeView: View {
    let ctaBannerResetID: UUID
    @Binding var showStatusBadges: Bool
    @Binding var showTranslationButton: Bool
    @Binding var tintColor: Color
    @Binding var textColor: Color
    let showsTranslationFallbackNote: Bool
    let openFeaturePulse: () -> Void
    let resetCTABanner: () -> Void

    var body: some View {
        List {
            Section {
                FeaturePulse.shared.ctaBanner(trigger: .manual { true })
                    .id(ctaBannerResetID)
                    .listRowInsets(EdgeInsets(.zero))
                    .listRowBackground(Color.clear)
            }

            Section {
                Button {
                    openFeaturePulse()
                } label: {
                    Label("Open FeaturePulse Modal", systemImage: "lightbulb")
                }
            }

            DemoSettingsSection(
                showStatusBadges: $showStatusBadges,
                showTranslationButton: $showTranslationButton,
                tintColor: $tintColor,
                textColor: $textColor,
                showsTranslationFallbackNote: showsTranslationFallbackNote
            )

            Section {
                Button {
                    resetCTABanner()
                } label: {
                    Label("Reset CTA Banner", systemImage: "arrow.counterclockwise")
                }
            }

            DemoUserSection()
        }
    }
}

#Preview {
    DemoHomeView(
        ctaBannerResetID: UUID(),
        showStatusBadges: .constant(true),
        showTranslationButton: .constant(false),
        tintColor: .constant(.pink),
        textColor: .constant(.white),
        showsTranslationFallbackNote: false,
        openFeaturePulse: {},
        resetCTABanner: {}
    )
}
