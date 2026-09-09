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
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-async-algorithms",
            from: "1.0.0",
        ),
    ],
    targets: [
        .target(
            name: "Metrics",
            dependencies: [
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
            ],
        ),
        .testTarget(
            name: "MetricsTests",
            dependencies: ["Metrics"],
        ),
    ],
)
