// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Routing",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "Routing", targets: ["Routing"])],
    targets: [.target(name: "Routing")]
)
