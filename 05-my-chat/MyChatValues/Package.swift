// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyChatValues",
    platforms: [.macOS(.v26), .iOS(.v26)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MyChatValues",
            targets: ["MyChatValues"]
        ),
    ],
    targets: [
        .target(
            name: "MyChatValues"
        ),
        .testTarget(
            name: "MyChatValuesTests",
            dependencies: ["MyChatValues"]
        ),
    ]
)
