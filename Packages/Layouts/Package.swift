// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Layouts",
    platforms: [
        .iOS(.v26),
    ],
    products: [
        .library(
            name: "LayoutsUI",
            targets: ["LayoutsUI"],
        ),
        .library(
            name: "LayoutsVM",
            targets: ["LayoutsVM"],
        ),
        .library(
            name: "LayoutsModel",
            targets: ["LayoutsModel"],
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "LayoutsModel",
            dependencies: [],
        ),
        .target(
            name: "LayoutsVM",
            dependencies: ["LayoutsModel"],
        ),
        .target(
            name: "LayoutsUI",
            dependencies: ["LayoutsVM", "LayoutsModel"],
        ),
        .testTarget(
            name: "LayoutsModelTests",
            dependencies: ["LayoutsModel"],
        ),
        .testTarget(
            name: "LayoutsVMTests",
            dependencies: ["LayoutsVM", "LayoutsModel"],
        ),
    ],
)
