// swift-tools-version:5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription


func products() -> [Product] {
    let products: [Product] = [
        .library(name: "PKCore", targets: ["PKCore"]),
        .library(name: "PKWebServer", targets: ["PKWebServer"]),
        .library(name: "PKUI", targets: ["PKUITarget"]),
        .library(name: "PKUtil", targets: ["PKUtil"])
    ]
    
    return products
}


func targets() -> [Target] {
    
    let targets: [Target] = [
        .target(name: "PKCore", path: "Sources/Core"),
        
        .target(name: "PKUI", path: "Sources/UI"),
        .target(name: "PKUIExtension", path: "Sources/UIExtension"),
        .target(name: "PKUITarget", dependencies: [
            .target(name: "PKUI", condition: .when(platforms: [.iOS])),
            .target(name: "PKUIExtension", condition: .when(platforms: [.iOS]))
        ], path: "Sources/UITarget"),
        
        
        .target(name: "PKUtil",
                dependencies: [
                    .target(name: "PKCore", condition: nil),
                ],
                path: "Sources/Util"),
        .target(
            name: "PKWebServer",
            dependencies: [
                .target(name: "PKCore", condition: nil),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOWebSocket", package: "swift-nio"),
            ],
            path: "Sources/WebServer",
            resources: [.process("Resources")]
        ),
        .testTarget(name: "WebServerTests",
                    dependencies: ["PKCore", "PKWebServer"]),
        .testTarget(name: "UITests",
                    dependencies: ["PKCore", "PKUI", "PKUIExtension"])
    ]
    

    return targets
}


let package = Package(
    name: "PKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v11)
    ],
    products: products(),
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.0.0"),
    ],
    targets: targets(),
    swiftLanguageVersions: [
        .v5
    ]
)
