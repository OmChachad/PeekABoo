// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PeekABoo",
    platforms: [
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "PeekABoo",
            targets: ["PeekABoo"]
        ),
    ],
    targets: [
        .target(
            name: "PeekABoo",
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
