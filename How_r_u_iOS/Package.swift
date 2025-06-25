// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "How_r_u_iOS",
    platforms: [.linux],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
    ],
    targets: [
        .executableTarget(
            name: "How_r_u_iOS",
            dependencies: [.product(name: "Vapor", package: "vapor")],
	    path: "Sources/How_r_u_iOS"
        )
    ]
)
