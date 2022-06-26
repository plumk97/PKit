// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription


let package = Package(
    name: "PKit",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "PKCore", targets: ["PKCore"]),
        .library(name: "PKUI", targets: ["PKUI"]),
        .library(name: "PKWebServer", targets: ["PKWebServer"]),
        .library(name: "PKJSON", targets: ["PKJSON"])
    ],
    dependencies: [
        .package(url: "https://gitee.com/mirrors/SwiftNIO", from: "2.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(name: "PKCore", path: "Sources/Core"),
        .target(name: "PKUI", path: "Sources/UI"),
        .target(
            name: "PKWebServer",
            dependencies: [
                .target(name: "PKCore", condition: nil),
                .productItem(name: "NIO", package: "SwiftNIO", condition: nil),
                .productItem(name: "NIOHTTP1", package: "SwiftNIO", condition: nil),
                .productItem(name: "NIOWebSocket", package: "SwiftNIO", condition: nil),
            ],
            path: "Sources/WebServer",
            resources: [.process("Resources")]
        ),
        .target(name: "PKJSON", path: "Sources/JSON"),
        .testTarget(name: "JSONTests",
                    dependencies: ["PKCore", "PKJSON"]),
        .testTarget(name: "WebServerTests",
                    dependencies: ["PKCore", "PKWebServer"]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
