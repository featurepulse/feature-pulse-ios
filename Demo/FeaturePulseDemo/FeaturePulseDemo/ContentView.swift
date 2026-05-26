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

    init() {
        let startOnFeedback = ProcessInfo.processInfo.environment["FEATUREPULSE_DEMO_START_FEEDBACK"] == "1"
        _selectedTab = State(initialValue: startOnFeedback ? .feedback : .home)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                List {
                    Section {
                        FeaturePulse.shared.ctaBanner(trigger: .manual { true })
                            .id(ctaBannerResetID)
                            .listRowInsets(EdgeInsets(.zero))
                            .listRowBackground(Color.clear)
                            .padding(.top)
                    }

                    Section("Demo user") {
                        LabeledContent("Plan", value: "Monthly")
                        LabeledContent("MRR", value: "$9.99")
                        LabeledContent("Custom ID", value: "demo-user")
                    }

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
                        if showTranslationButton, shouldShowTranslationFallbackNote {
                            Text("""
                            Translation is available on iOS 18+ for non-English locales. \
                            On Simulator, the native translation UI may not appear until \
                            language support is available.
                            """)
                        }
                    }

                    Section {
                        Button {
                            showFeedback = true
                        } label: {
                            Label("Open FeaturePulse", systemImage: "lightbulb")
                        }

                        Button {
                            resetCTABannerDismissal()
                            withAnimation {
                                ctaBannerResetID = UUID()
                            }
                        } label: {
                            Label("Reset CTA Banner", systemImage: "arrow.counterclockwise")
                        }
                    }
                }
                .navigationTitle("FeaturePulse Demo")
                .tint(tintColor)
                .onChange(of: tintColor) { newValue in
                    FeaturePulse.shared.primaryColor = newValue
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
                        FeaturePulse.shared.view()
                            .id(featurePulseViewID)
                            .environment(\.locale, featurePulseLocale)
                            .toolbar {
                                ToolbarItem(placement: .topBarLeading) {
                                    if #available(iOS 26, *) {
                                        Button(role: .close) { showFeedback = false }
                                    } else {
                                        Button { showFeedback = false } label: {
                                            Label("Close", systemImage: "xmark")
                                        }
                                    }
                                }
                            }
                    }
                }
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(DemoTab.home)

            NavigationStack {
                FeaturePulse.shared.view()
                    .id(featurePulseViewID)
                    .environment(\.locale, featurePulseLocale)
                    .navigationTitle("Feedback")
            }
            .tabItem {
                Label("Feedback", systemImage: "lightbulb")
            }
            .tag(DemoTab.feedback)
        }
    }

    private func resetCTABannerDismissal() {
        UserDefaults.standard.set(false, forKey: DemoStorageKey.ctaBannerDismissed)
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
