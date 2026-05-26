import FeaturePulse
import SwiftUI

struct ContentView: View {
    private enum DemoStorageKey {
        static let ctaBannerDismissed = "se.featurepul.ctaDismissed"
    }

    private enum DemoTab: Hashable {
        case home
        case feedback
    }

    @State private var selectedTab: DemoTab
    @State private var showFeedback = false
    @State private var showStatusBadges = true
    @State private var showTranslationButton = false
    @State private var tintColor: Color = .pink
    @State private var textColor: Color = .white
    @State private var ctaBannerResetID = UUID()
    @State private var featurePulseViewID = UUID()
    @State private var tabViewID = UUID()

    init() {
        let startOnFeedback = ProcessInfo.processInfo.environment["FEATUREPULSE_DEMO_START_FEEDBACK"] == "1"
        _selectedTab = State(initialValue: startOnFeedback ? .feedback : .home)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DemoHomeView(
                    ctaBannerResetID: ctaBannerResetID,
                    showStatusBadges: $showStatusBadges,
                    showTranslationButton: $showTranslationButton,
                    tintColor: $tintColor,
                    textColor: $textColor,
                    showsTranslationFallbackNote: shouldShowTranslationFallbackNote,
                    openFeaturePulse: { showFeedback = true },
                    resetCTABanner: resetCTABanner
                )
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        DemoPackageTitleView()
                    }
                }
                .onChange(of: tintColor) { newValue in
                    FeaturePulse.shared.primaryColor = newValue
                    tabViewID = UUID()
                    refreshFeaturePulseViews()
                }
                .onChange(of: textColor) { newValue in
                    FeaturePulse.shared.foregroundColor = newValue
                    refreshFeaturePulseViews()
                }
                .onChange(of: showStatusBadges) { _ in
                    updateMockServerSettings()
                }
                .onChange(of: showTranslationButton) { _ in
                    updateMockServerSettings()
                }
                .task {
                    await loadMockServerSettings()
                }
                .sheet(isPresented: $showFeedback) {
                    NavigationStack {
                        FeaturePulseEmbeddedView(
                            featurePulseViewID: featurePulseViewID,
                            locale: featurePulseLocale,
                            onClose: { showFeedback = false }
                        )
                    }
                }
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(DemoTab.home)

            NavigationStack {
                FeaturePulseEmbeddedView(
                    featurePulseViewID: featurePulseViewID,
                    locale: featurePulseLocale,
                    navigationTitle: "Feedback"
                )
            }
            .tabItem {
                Label("Feedback", systemImage: "lightbulb")
            }
            .tag(DemoTab.feedback)
        }
        .id(tabViewID)
        .tint(tintColor)
    }

    private func resetCTABanner() {
        UserDefaults.standard.set(false, forKey: DemoStorageKey.ctaBannerDismissed)
        withAnimation {
            ctaBannerResetID = UUID()
        }
    }

    private var mockSettingsURL: URL? {
        URL(string: FeaturePulse.shared.baseURL)?.appending(path: "api/mock/settings")
    }

    private var featurePulseLocale: Locale {
        showTranslationButton ? Locale(identifier: "ar") : .current
    }

    private var shouldShowTranslationFallbackNote: Bool {
        #if targetEnvironment(simulator)
            if #available(iOS 18.0, *) {
                return true
            } else {
                return false
            }
        #else
            return false
        #endif
    }

    private func updateMockServerSettings() {
        Task {
            guard let mockSettingsURL else { return }

            var request = URLRequest(url: mockSettingsURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: [
                "show_status": showStatusBadges,
                "show_translation": showTranslationButton
            ])

            _ = try? await URLSession.shared.data(for: request)

            await MainActor.run { refreshFeaturePulseViews() }
        }
    }

    private func refreshFeaturePulseViews() {
        ctaBannerResetID = UUID()
        featurePulseViewID = UUID()
    }

    @MainActor
    private func loadMockServerSettings() async {
        guard let mockSettingsURL else { return }

        guard
            let (data, _) = try? await URLSession.shared.data(from: mockSettingsURL),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return
        }

        showStatusBadges = json["show_status"] as? Bool ?? showStatusBadges
        showTranslationButton = json["show_translation"] as? Bool ?? showTranslationButton
    }
}

#Preview {
    ContentView()
}
