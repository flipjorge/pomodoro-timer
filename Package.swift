// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PomodoroTimer",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "PomodoroTimer",
            targets: ["PomodoroTimer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/flipjorge/seconds-timer.git", .branch("master"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "PomodoroTimer",
            dependencies: ["SecondsTimer"]),
        .testTarget(
            name: "PomodoroTimerTests",
            dependencies: ["PomodoroTimer"]),
    ]
)
