// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "StudyBuddy",
    platforms: [
        .iOS(.v16)
    ],
    dependencies: [
        .package(url: "https://github.com/supabase-community/supabase-swift.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.1.0")
    ],
    targets: [
        .target(
            name: "StudyBuddy",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "Crypto", package: "swift-crypto")
            ]
        )
    ]
) 