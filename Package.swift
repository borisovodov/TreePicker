// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "TreePicker",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "TreePicker",
            targets: ["TreePicker"]),
    ],
    targets: [
        .target(
            name: "TreePicker"),
        .testTarget(
            name: "TreePickerTests",
            dependencies: ["TreePicker"]),
    ]
)
