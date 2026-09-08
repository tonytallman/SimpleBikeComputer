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
        .package(path: "../Location"),
        .package(path: "../Metrics"),
        .package(path: "../Pages"),
        .package(path: "../Root"),
        .package(path: "../Settings"),
    ],
    targets: [
        .target(
            name: "DependencyContainer",
            dependencies: [
                .product(name: "LayoutsModel", package: "Layouts"),
                .product(name: "LayoutsVM", package: "Layouts"),
                "Location",
                "Metrics",
                .product(name: "PagesVM", package: "Pages"),
                .product(name: "RootVM", package: "Root"),
                .product(name: "SettingsVM", package: "Settings"),
            ],
        ),
    ],
)
