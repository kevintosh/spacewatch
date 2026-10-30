// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SpaceWatch",
    platforms: [.macOS(.v13)],
    products: [.executable(name: "spacewatch", targets: ["SpaceWatch"])],
    targets: [.executableTarget(name: "SpaceWatch", path: "Sources/SpaceWatch")]
)
