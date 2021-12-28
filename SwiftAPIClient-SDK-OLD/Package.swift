// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftAPIClientRemote",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftAPIClient",
            targets: ["SwiftAPIClient"]
        ),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "SwiftAPIClient",
            path: "./sources/SwiftAPIClient.xcframework"
        ),
//        .binaryTarget(
//            name: "SwiftAPIClient",
//            url: "https://github.com/RichAppz/SwiftAPIClient/blob/master/SwiftAPIClient.xcframework.zip",
//            checksum: "788d0f1095344f8c135e47d0faab6cd90f24bda3b7812a2378aa0da00ee8f918"
//        )
    ]
)
