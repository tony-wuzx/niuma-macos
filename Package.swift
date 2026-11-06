// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "NiuMa",
    platforms: [.macOS(.v13)],
    products: [.executable(name: "NiuMa", targets: ["NiuMa"])],
    targets: [
        .executableTarget(
            name: "NiuMa",
            path: "Sources/NiuMa",
            swiftSettings: [.unsafeFlags(["-strict-concurrency=minimal"])]
        )
    ]
)
