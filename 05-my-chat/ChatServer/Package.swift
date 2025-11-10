// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "ChatServer",
    platforms: [
        .macOS(.v26)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        .package(url: "https://github.com/team-budjam/swift-logger.git", from: "0.1.0"),
        .package(path: "../MyChatValues")
    ],
    targets: [
        .executableTarget(
            name: "ChatServer",
            dependencies: [
                .product(name: "MyChatValues", package: "MyChatValues"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "SwiftLogger", package: "swift-logger")
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "ChatServerTests",
            dependencies: [
                .target(name: "ChatServer"),
                .product(name: "VaporTesting", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        )
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
] }
