// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let package = Package(
    name: "SnapshotTestingWebP",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "SnapshotTestingWebP",
            targets: ["SnapshotTestingWebP"]),
    ],
    dependencies: [
        .package(name: "swift-snapshot-testing",
                 url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
                 from: "1.18.9"),
        .package(url: "https://github.com/the-swift-collective/libwebp.git", from: "1.4.1"),
    ],
    targets: [
        .target(
            name: "SnapshotTestingWebP",
            dependencies: [
                .product(name: "SnapshotTesting",
                         package: "swift-snapshot-testing"),
                .product(name: "WebP", package: "libwebp"),
                .product(name: "libwebp", package: "libwebp"),
            ]
        ),
        .testTarget(
            name: "SnapshotTestingWebPTests",
            dependencies: ["SnapshotTestingWebP"],
            exclude: ["__Snapshots__"]
        ),
    ]
)
