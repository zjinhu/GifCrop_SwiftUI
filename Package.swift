// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GifCrop_SwiftUI",
    products: [
        .library(
            name: "GifCrop_SwiftUI",
            targets: ["GifCrop_SwiftUI"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/zjinhu/Brick_SwiftUI.git", .upToNextMajor(from: "0.3.0")),
    ],
    targets: [
        .target(name: "GifCrop_SwiftUI",
                dependencies: [
                    .product(name: "BrickKit", package: "Brick_SwiftUI"),
                ]
               ),
    ]
)
package.platforms = [
    .iOS(.v14),
]
package.swiftLanguageVersions = [.v5]

