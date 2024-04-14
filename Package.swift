// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "TreePicker",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
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
