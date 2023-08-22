// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "DataSource",
  platforms: [.macOS(.v13)],

  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "DataSource",
      targets: ["DataSource"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/apple/swift-collections.git",
      .upToNextMinor(from: "1.0.0") // or `.upToNextMajor
    )
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "DataSource",
      dependencies: [
        .product(name: "Collections", package: "swift-collections")
      ]
    ),
    .testTarget(
      name: "DataSourceTests",
      dependencies: ["DataSource"]),
  ]
)
