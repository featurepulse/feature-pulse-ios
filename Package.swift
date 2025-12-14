// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "FeaturePulse",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "FeaturePulse",
            targets: ["FeaturePulse"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/codykerns/StableID", from: "0.4.1")
    ],
    targets: [
        .target(
            name: "FeaturePulse",
            dependencies: [
                .product(name: "StableID", package: "StableID")
            ],
            resources: [
                .process("Resources"),
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
