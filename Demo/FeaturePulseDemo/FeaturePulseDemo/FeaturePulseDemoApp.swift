import FeaturePulse
import SwiftUI

@main
struct FeaturePulseDemoApp: App {
    let tintColor: Color = .pink

    init() {
        let useMockAPI = ProcessInfo.processInfo.environment["FEATUREPULSE_USE_MOCKS"] != "0"

        if useMockAPI {
            FeaturePulse.shared.baseURL = ProcessInfo.processInfo.environment["FEATUREPULSE_BASE_URL"] ?? "http://127.0.0.1:8765"
        }

        FeaturePulse.shared.apiKey = ProcessInfo.processInfo.environment["FEATUREPULSE_API_KEY"] ?? "demo-api-key"
        FeaturePulse.shared.primaryColor = tintColor
        FeaturePulse.shared.foregroundColor = .white
        FeaturePulse.shared.updateUser(customID: "demo-user")
        FeaturePulse.shared.updateUser(payment: .monthly(9.99, currency: "USD"))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .featurePulseSessionTracking()
                .tint(tintColor)
        }
    }
}
