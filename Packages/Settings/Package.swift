// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Settings",
    platforms: [
        .iOS(.v26),
    ],
    products: [
        .library(
            name: "SettingsUI",
            targets: ["SettingsUI"],
        ),
        .library(
            name: "SettingsVM",
            targets: ["SettingsVM"],
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SettingsVM",
            dependencies: [],
        ),
        .target(
            name: "SettingsUI",
            dependencies: [
                "SettingsVM",
            ],
        ),
    ],
)
