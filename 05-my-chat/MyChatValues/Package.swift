// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyChatValues",
    platforms: [.macOS(.v26), .iOS(.v26)],
    products: [
        .library(
            name: "MyChatValues",
            targets: ["MyChatValues"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/team-budjam/swift-logger.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "MyChatValues",
            dependencies: [
                .product(name: "SwiftLogger", package: "swift-logger")
            ]
        ),
        .testTarget(
            name: "MyChatValuesTests",
            dependencies: ["MyChatValues"]
        ),
    ]
)
