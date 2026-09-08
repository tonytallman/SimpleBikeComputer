// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Location",
    platforms: [
        .iOS(.v26),
    ],
    products: [
        .library(
            name: "Location",
            targets: ["Location"],
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Location",
            dependencies: [],
        ),
        .testTarget(
            name: "LocationTests",
            dependencies: ["Location"],
        ),
    ],
)
