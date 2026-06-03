import SwiftUI
import UIKit

struct DemoSettingsSection: View {
    @Binding var showStatusBadges: Bool
    @Binding var showTranslationButton: Bool
    @Binding var isDeveloperFreePlan: Bool
    @Binding var tintColor: Color
    @Binding var textColor: Color
    let showsTranslationFallbackNote: Bool

    var body: some View {
        Section {
            Toggle("Show Status Badges", isOn: $showStatusBadges)

            if #available(iOS 18.0, *) {
                Toggle("Show Translation Button", isOn: $showTranslationButton)
            }

            Button {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            } label: {
                Label("App Language Settings", systemImage: "globe")
            }

            ColorPicker("Tint Color", selection: $tintColor, supportsOpacity: false)

            ColorPicker("Text Color", selection: $textColor, supportsOpacity: false)
        } header: {
            Text("SDK Settings")
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

struct DemoDeveloperStateSection: View {
    @Binding var isDeveloperFreePlan: Bool

    var body: some View {
        Section {
            Toggle("Developer Free Plan", isOn: $isDeveloperFreePlan)
        } header: {
            Text("Developer State")
        } footer: {
            Text("Free plan shows the FeaturePulse watermark, matching the developer's subscription state.")
        }
    }
}

#Preview {
    List {
        DemoSettingsSection(
            showStatusBadges: .constant(true),
            showTranslationButton: .constant(false),
            isDeveloperFreePlan: .constant(false),
            tintColor: .constant(.pink),
            textColor: .constant(.white),
            showsTranslationFallbackNote: false
        )
        DemoDeveloperStateSection(isDeveloperFreePlan: .constant(false))
    }
}
