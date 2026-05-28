// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AllocatedUnfairLock",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .tvOS(.v18),
        .visionOS(.v2),
        .watchOS(.v11),
    ],
    products: [
        .library(
            name: "AllocatedUnfairLock",
            targets: ["AllocatedUnfairLock"]
        ),
    ],
    targets: [
        .target(
            name: "AllocatedUnfairLock"
        ),
        .testTarget(
            name: "AllocatedUnfairLockTests",
            dependencies: ["AllocatedUnfairLock"]
        ),
    ]
)
