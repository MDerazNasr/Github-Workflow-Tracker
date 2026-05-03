// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "GitPulse",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "GitPulse", targets: ["GitPulseApp"]),
        .library(name: "GitPulseCore", targets: ["GitPulseCore"])
    ],
    targets: [
        .target(
            name: "GitPulseCore",
            resources: [
                .copy("Resources/GitPulse.icns")
            ]
        ),
        .executableTarget(
            name: "GitPulseApp",
            dependencies: ["GitPulseCore"]
        ),
        .testTarget(
            name: "GitPulseCoreTests",
            dependencies: ["GitPulseCore"]
        )
    ]
)
