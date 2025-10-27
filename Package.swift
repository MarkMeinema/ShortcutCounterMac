// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ShortcutCounter",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "ShortcutCounter",
            targets: ["ShortcutCounter"])
    ],
    targets: [
        .executableTarget(
            name: "ShortcutCounter",
            dependencies: []
        )
    ]
)