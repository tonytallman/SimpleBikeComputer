// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "DependencyContainer",
    platforms: [
        .iOS(.v26),
    ],
    products: [
        .library(
            name: "DependencyContainer",
            targets: ["DependencyContainer"],
        ),
    ],
    dependencies: [
        .package(path: "../Layouts"),
    ],
    targets: [
        .target(
            name: "DependencyContainer",
            dependencies: [
                .product(name: "LayoutsModel", package: "Layouts"),
                .product(name: "LayoutsVM", package: "Layouts"),
            ],
        ),
    ],
)
