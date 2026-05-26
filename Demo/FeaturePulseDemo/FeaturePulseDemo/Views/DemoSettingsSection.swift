import SwiftUI

struct DemoSettingsSection: View {
    @Binding var showStatusBadges: Bool
    @Binding var showTranslationButton: Bool
    @Binding var tintColor: Color
    @Binding var textColor: Color
    let showsTranslationFallbackNote: Bool

    var body: some View {
        Section {
            Toggle("Show Status Badges", isOn: $showStatusBadges)

            if #available(iOS 18.0, *) {
                Toggle("Show Translation Button", isOn: $showTranslationButton)
            }

            ColorPicker("Tint Color", selection: $tintColor, supportsOpacity: false)

            ColorPicker("Text Color", selection: $textColor, supportsOpacity: false)
        } header: {
            Text("SwiftUI native components")
        } footer: {
            if showTranslationButton, showsTranslationFallbackNote {
                Text("""
                Translation is available on iOS 18+ for non-English locales. \
                On Simulator, the native translation UI may not appear until \
                language support is available.
                """)
            }
        }
    }
}

#Preview {
    List {
        DemoSettingsSection(
            showStatusBadges: .constant(true),
            showTranslationButton: .constant(false),
            tintColor: .constant(.pink),
            textColor: .constant(.white),
            showsTranslationFallbackNote: false
        )
    }
}
