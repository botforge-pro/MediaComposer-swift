// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MediaComposer",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MediaComposer",
            targets: ["MediaComposer"]
        )
    ],
    targets: [
        .target(
            name: "MediaComposer",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
