// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "AutoCleaner",
    products: [
        .library(name: "AutoCleaner", targets: ["AutoCleaner"]),
    ],
    targets: [
        .target(name: "AutoCleaner", dependencies: []),
        .testTarget(name: "AutoCleanerTests", dependencies: ["AutoCleaner"]),
    ],
    swiftLanguageVersions: [.v5]
)
