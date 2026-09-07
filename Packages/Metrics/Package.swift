// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Metrics",
    platforms: [
        .iOS(.v26),
    ],
    products: [
        .library(
            name: "Metrics",
            targets: ["Metrics"],
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Metrics",
            dependencies: [],
        ),
        .testTarget(
            name: "MetricsTests",
            dependencies: ["Metrics"],
        ),
    ],
)
