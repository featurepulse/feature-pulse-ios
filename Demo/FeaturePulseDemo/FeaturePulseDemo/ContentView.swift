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
    @State private var ctaBannerResetID = UUID()

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
                        Button {
                            showFeedback = true
                        } label: {
                            Label("Open FeaturePulse", systemImage: "lightbulb")
                        }

                        Button {
                            resetCTABannerDismissal()
                            ctaBannerResetID = UUID()
                        } label: {
                            Label("Reset CTA Banner", systemImage: "arrow.counterclockwise")
                        }
                    }
                }
                .navigationTitle("FeaturePulse Demo")
                .sheet(isPresented: $showFeedback) {
                    NavigationStack {
                        FeaturePulse.shared.view()
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
}

#Preview {
    ContentView()
}
