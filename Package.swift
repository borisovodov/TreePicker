// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "TreePicker",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v16),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "TreePicker",
            type: .static,
            targets: ["TreePicker"]),
    ],
    targets: [
        .target(
            name: "TreePicker",
            resources: [.process("Resources")],
        ),
        .testTarget(
            name: "TreePickerTests",
            dependencies: ["TreePicker"],
        ),
    ],
    swiftLanguageModes: [.v6]
)
