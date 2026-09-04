// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Pages",
    platforms: [
        .iOS(.v26),
    ],
    products: [
        .library(
            name: "PagesUI",
            targets: ["PagesUI"],
        ),
        .library(
            name: "PagesVM",
            targets: ["PagesVM"],
        ),
    ],
    dependencies: [
        .package(path: "../Layouts"),
    ],
    targets: [
        .target(
            name: "PagesVM",
            dependencies: [
                .product(name: "LayoutsVM", package: "Layouts"),
            ],
        ),
        .target(
            name: "PagesUI",
            dependencies: [
                "PagesVM",
                .product(name: "LayoutsUI", package: "Layouts"),
            ],
        ),
        .testTarget(
            name: "PagesVMTests",
            dependencies: [
                "PagesVM",
                .product(name: "LayoutsVM", package: "Layouts"),
                .product(name: "LayoutsModel", package: "Layouts"),
            ],
        ),
    ],
)
