// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ProducerGraph",
  platforms: [
    .iOS(.v14),
    .macOS(.v12)
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-async-algorithms", from: "0.0.0"),
  ],
  targets: [
    .executableTarget(
      name: "SupplyChain",
      dependencies: [
        .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
      ]
    ),
    .executableTarget(
      name: "ProducerGraph",
      dependencies: [
        .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
      ]
    ),
    .executableTarget(
      name: "ProducerGraph2",
      dependencies: [
        // .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
      ]
    ),
    .executableTarget(
      name: "TopologicalSort",
      dependencies: [
        // .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
      ]
    ),
    .testTarget(
      name: "ProducerGraphTests",
      dependencies: ["ProducerGraph"]
    ),
  ]
)

