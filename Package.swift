// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "ContentfulRichTextRenderer",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "ContentfulRichTextRenderer",
            targets: ["RichTextRenderer"])
    ],
    dependencies: [
        .package(
            name: "Contentful",
            url: "https://github.com/contentful/contentful.swift.git",
            from: "5.2.0"
        ),
        .package(
            name: "AlamofireImage",
            url: "https://github.com/Alamofire/AlamofireImage.git",
            from: "4.1.0"
        )
    ],
    targets: [
        .target(
            name: "RichTextRenderer",
            dependencies: ["Contentful", "AlamofireImage"],
            path: "Sources"
        )
    ],
    swiftLanguageVersions: [.v5]
)
