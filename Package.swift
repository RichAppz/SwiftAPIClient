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
//        .binaryTarget(
//            name: "SwiftAPIClient",
//            path: "./output/SwiftAPIClient.xcframework"
//        ),
        .binaryTarget(
            name: "SwiftAPIClient",
            url: "https://github.com/RichAppz/SwiftAPIClient/blob/master/output/SwiftAPIClient.xcframework.zip",
            checksum: "1bbe7471963cf5b5699d005a00676e241faa7cfbb07b2aece62f917bddbf9105"
        )
    ]
)
