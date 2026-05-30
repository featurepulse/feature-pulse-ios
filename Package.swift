// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "FeaturePulse",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "FeaturePulse",
            targets: ["FeaturePulse"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "FeaturePulse",
            dependencies: [],
            resources: [
                .process("Resources"),
                .process("PrivacyInfo.xcprivacy")
            ]
        ),
        .testTarget(
            name: "FeaturePulseTests",
            dependencies: ["FeaturePulse"]
        )
    ]
)
