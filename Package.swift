// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Swen",
    products: [
        .library(
            name: "Swen",
            targets: ["Swen"]
        )
    ],
    targets: [
        .target(name: "Swen"),
        .testTarget(
            name: "SwenTests",
            dependencies: ["Swen"],
            path: "Tests"
        )
    ]
)
