// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "project7",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMinor(from: "3.3.0")),
        .package(url: "https://github.com/vapor/fluent-sqlite.git", .upToNextMinor(from: "3.0.0")),
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "FluentSQLite"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)

