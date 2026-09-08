// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Root",
    platforms: [
        .iOS(.v26),
    ],
    products: [
        .library(
            name: "RootUI",
            targets: ["RootUI"],
        ),
        .library(
            name: "RootVM",
            targets: ["RootVM"],
        ),
    ],
    dependencies: [
        .package(path: "../Layouts"),
        .package(path: "../Pages"),
        .package(path: "../Settings"),
    ],
    targets: [
        .target(
            name: "RootVM",
            dependencies: [
                .product(name: "PagesVM", package: "Pages"),
                .product(name: "SettingsVM", package: "Settings"),
            ],
        ),
        .target(
            name: "RootUI",
            dependencies: [
                "RootVM",
                .product(name: "PagesUI", package: "Pages"),
                .product(name: "SettingsUI", package: "Settings"),
            ],
        ),
        .testTarget(
            name: "RootVMTests",
            dependencies: [
                "RootVM",
                .product(name: "PagesVM", package: "Pages"),
                .product(name: "LayoutsVM", package: "Layouts"),
                .product(name: "LayoutsModel", package: "Layouts"),
                .product(name: "SettingsVM", package: "Settings"),
            ],
        ),
    ],
)
