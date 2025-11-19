// swift-tools-version: 5.9
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
      targets: ["FeaturePulseWrapper"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/codykerns/StableID", from: "0.4.1")
  ],
  targets: [
    .binaryTarget(
      name: "FeaturePulseBinary",
      path: "Sources/FeaturePulse.xcframework"
    ),
    .target(
      name: "FeaturePulseWrapper",
      dependencies: [
        "FeaturePulseBinary",
        .product(name: "StableID", package: "StableID"),
      ]
    ),
  ]
)
