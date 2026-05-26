import SwiftUI

struct DemoPackageTitleView: View {
    var body: some View {
        Image("Logo", bundle: .featurePulseResources)
            .resizable()
            .scaledToFit()
            .frame(height: 24)
            .accessibilityLabel("FeaturePulse Swift Package demo")
    }
}

private extension Bundle {
    static var featurePulseResources: Bundle {
        let url = Bundle.main.url(forResource: "FeaturePulse_FeaturePulse", withExtension: "bundle")
        if let url, let bundle = Bundle(url: url) {
            return bundle
        }
        return Bundle.allBundles.first {
            $0.bundleURL.lastPathComponent == "FeaturePulse_FeaturePulse.bundle"
        } ?? .main
    }
}

#Preview {
    DemoPackageTitleView()
        .padding()
}
