// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "APRater",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "APRater",
            targets: ["APRater"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/sunshinejr/SwiftyUserDefaults.git", from: "5.3.0"),
        .package(url: "https://github.com/SwifterSwift/SwifterSwift.git", from: "8.0.0")
    ],
    targets: [
        .target(
            name: "APRater",
            dependencies: [
                "SwiftyUserDefaults",
                "SwifterSwift"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "APRaterTests",
            dependencies: ["APRater"],
            path: "Tests"
        )
    ],
    swiftLanguageVersions: [.v5, .v6]
)
