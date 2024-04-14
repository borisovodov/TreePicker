// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "HierarchicalPicker",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "HierarchicalPicker",
            targets: ["HierarchicalPicker"]),
    ],
    targets: [
        .target(
            name: "HierarchicalPicker"),
        .testTarget(
            name: "HierarchicalPickerTests",
            dependencies: ["HierarchicalPicker"]),
    ]
)
