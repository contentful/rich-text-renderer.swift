<p align="center">
  <a href="https://www.contentful.com/slack/">
    <img src="https://img.shields.io/badge/-Join%20Community%20Slack-2AB27B.svg?logo=slack&maxAge=31557600" alt="Join Contentful Community Slack">
  </a>
  &nbsp;
  <a href="https://www.contentfulcommunity.com/">
    <img src="https://img.shields.io/badge/-Join%20Community%20Forum-3AB2E6.svg?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA1MiA1OSI+CiAgPHBhdGggZmlsbD0iI0Y4RTQxOCIgZD0iTTE4IDQxYTE2IDE2IDAgMCAxIDAtMjMgNiA2IDAgMCAwLTktOSAyOSAyOSAwIDAgMCAwIDQxIDYgNiAwIDEgMCA5LTkiIG1hc2s9InVybCgjYikiLz4KICA8cGF0aCBmaWxsPSIjNTZBRUQyIiBkPSJNMTggMThhMTYgMTYgMCAwIDEgMjMgMCA2IDYgMCAxIDAgOS05QTI5IDI5IDAgMCAwIDkgOWE2IDYgMCAwIDAgOSA5Ii8+CiAgPHBhdGggZmlsbD0iI0UwNTM0RSIgZD0iTTQxIDQxYTE2IDE2IDAgMCAxLTIzIDAgNiA2IDAgMSAwLTkgOSAyOSAyOSAwIDAgMCA0MSAwIDYgNiAwIDAgMC05LTkiLz4KICA8cGF0aCBmaWxsPSIjMUQ3OEE0IiBkPSJNMTggMThhNiA2IDAgMSAxLTktOSA2IDYgMCAwIDEgOSA5Ii8+CiAgPHBhdGggZmlsbD0iI0JFNDMzQiIgZD0iTTE4IDUwYTYgNiAwIDEgMS05LTkgNiA2IDAgMCAxIDkgOSIvPgo8L3N2Zz4K&maxAge=31557600"
      alt="Join Contentful Community Forum">
  </a>
</p>

# rich-text-renderer.swift - Native Rich Text Rendering for Contentful

> Renders Contentful [Rich Text](https://www.contentful.com/developers/docs/concepts/rich-text/) fields to `NSAttributedString`, with native `UIView`s embedded directly in the text. Built on top of [TextKit](https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/CustomTextProcessing/CustomTextProcessing.html) and the official [contentful.swift](https://github.com/contentful/contentful.swift) library, it provides a powerful plugin system for rendering the Contentful entries and assets embedded in your rich text.

<p align="center">
  <img src="https://img.shields.io/badge/Status-Maintained-green.svg" alt="This repository is actively maintained" />
  &nbsp;
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License" />
  </a>
</p>

<p align="center">
  <a href="https://cocoapods.org/pods/ContentfulRichTextRenderer">
    <img src="https://img.shields.io/cocoapods/v/ContentfulRichTextRenderer.svg?style=flat" alt="Version">
  </a>
  &nbsp;
  <a href="https://github.com/Carthage/Carthage">
    <img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage compatible">
  </a>
  &nbsp;
  <a href="https://swift.org/package-manager/">
    <img src="https://rawgit.com/jlyonsmith/artwork/master/SwiftPackageManager/swiftpackagemanager-compatible.svg" alt="Swift Package Manager compatible">
  </a>
  &nbsp;
  <a href="https://swift.org/package-manager/">
    <img src="https://img.shields.io/cocoapods/p/ContentfulRichTextRenderer.svg?style=flat" alt="iOS">
  </a>
  &nbsp;
</p>

**What is Contentful?**

[Contentful](https://www.contentful.com/) provides content infrastructure for digital teams to power websites, apps, and devices. Unlike a CMS, Contentful was built to integrate with the modern software stack. It offers a central hub for structured content, powerful management and delivery APIs, and a customizable web app that enable developers and content creators to ship their products faster.

<details>
<summary>Table of contents</summary>
<!-- TOC -->

- [rich-text-renderer.swift - Native Rich Text Rendering for Contentful](#rich-text-rendererswift---native-rich-text-rendering-for-contentful)
  - [Core Features](#core-features)
  - [Getting started](#getting-started)
    - [Requirements](#requirements)
    - [Installation](#installation)
      - [Swift Package Manager](#swift-package-manager)
      - [CocoaPods](#cocoapods)
      - [Carthage](#carthage)
    - [Your first render](#your-first-render)
  - [Using the SDK](#using-the-sdk)
    - [Renderer configuration](#renderer-configuration)
    - [Rendering views for `ResourceLinkBlock` nodes](#rendering-views-for-resourcelinkblock-nodes)
    - [Rendering `ResourceLinkInline` nodes](#rendering-resourcelinkinline-nodes)
    - [Handling hyperlink taps](#handling-hyperlink-taps)
    - [Custom node renderers](#custom-node-renderers)
    - [Tables](#tables)
  - [Advanced configuration](#advanced-configuration)
    - [Styling text, headings, and lists](#styling-text-headings-and-lists)
    - [Dark mode](#dark-mode)
    - [Privacy manifest](#privacy-manifest)
  - [Documentation & References](#documentation--references)
    - [Example applications](#example-applications)
  - [Reach out to us](#reach-out-to-us)
    - [Have questions about how to use this library?](#have-questions-about-how-to-use-this-library)
    - [You found a bug or want to propose a feature?](#you-found-a-bug-or-want-to-propose-a-feature)
    - [You need to share confidential information or have other questions?](#you-need-to-share-confidential-information-or-have-other-questions)
  - [Get involved](#get-involved)
  - [License](#license)
  - [Code of Conduct](#code-of-conduct)

<!-- /TOC -->

</details>

## Core Features

- Renders `Contentful.RichTextDocument` to `NSAttributedString`, displayed via a ready-to-use `RichTextViewController` built on `TextKit`.
- Native `UIView`s wrap text for embedded block-level entries and assets (`ResourceLinkBlock`), with word-wrap-aware layout via a custom `NSLayoutManager`/`NSTextContainer`.
- Pluggable rendering for embedded content: implement `ResourceLinkBlockViewProviding` for block-level entries/assets and `ResourceLinkInlineStringProviding` for inline entries, so your own `EntryDecodable` types render as first-class views or styled text runs.
- Override any node renderer (paragraphs, headings, lists, block quotes, hyperlinks, tables, and more) by subclassing the default renderer and attaching it to a `DefaultRenderersProvider`.
- Built-in table rendering with a `SimpleTableView` implementation, or supply your own.
- Blockquote styling with a configurable rule/rectangle, drawn via a custom layout manager decoration — matching the look of blockquotes on the web.
- Fully configurable typography via `StyleProviding` (regular/bold/italic/bold-italic/monospace fonts and colors, heading styles, hyperlink color), plus `TextConfiguration`, `BlockQuoteConfiguration`, and `TextListConfiguration`.
- Automatic dark-mode-aware default colors (`UIColor.rtrLabel`, `UIColor.rtrSystemBackground`).
- Callbacks for intercepting taps on URL hyperlinks (`onHyperlinkPressed`) and links to Contentful entries/assets (`onResourceHyperlinkPressed`).
- Ships with a [privacy manifest](PrivacyInfo.xcprivacy) for App Store submissions.

## Getting started

- [Requirements](#requirements)
- [Installation](#installation)
- [Your first render](#your-first-render)

### Requirements

| Requirement | Version |
| --- | --- |
| Swift | 5.2 or later |
| iOS | 13.0+ |

The SDK depends on [contentful.swift](https://github.com/contentful/contentful.swift) and [AlamofireImage](https://github.com/Alamofire/AlamofireImage) (used for loading and caching images for `ResourceLinkBlockImageView`).

### Installation

#### Swift Package Manager

[Swift Package Manager](https://swift.org/package-manager/) is the recommended way to integrate the SDK. In Xcode, choose **File > Add Package Dependencies…** and enter `https://github.com/contentful/rich-text-renderer.swift`, or add the dependency to your `Package.swift` manifest:

```swift
.package(url: "https://github.com/contentful/rich-text-renderer.swift", from: "0.4.10")
```

Then add the product to the targets that need it:

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "ContentfulRichTextRenderer", package: "rich-text-renderer.swift")
    ]
)
```

The library's module is named `RichTextRenderer` when installed via Swift Package Manager, so import it as:

```swift
import RichTextRenderer
```

#### CocoaPods

> [!IMPORTANT]
> **CocoaPods is frozen at version 0.4.10.** The [CocoaPods trunk becomes read-only on December 2, 2026](https://blog.cocoapods.org/CocoaPods-Specs-Repo/), so new versions of this library are no longer published to CocoaPods. Existing versions stay installable, and the snippet below keeps working. New releases ship through [Swift Package Manager](#swift-package-manager) (recommended) and [Carthage](#carthage) only.

```ruby
platform :ios, '13.0'
use_frameworks!
pod 'ContentfulRichTextRenderer', '~> 0.4.10'
```

When installed via CocoaPods, the module name matches the pod name, so import it as:

```swift
import ContentfulRichTextRenderer
```

#### Carthage

Add the following to your `Cartfile`:

```
github "contentful/rich-text-renderer.swift" ~> 0.4.10
```

Then build the XCFrameworks:

```bash
carthage update --platform iOS --use-xcframeworks
```

Add the four XCFrameworks from `Carthage/Build` to your app target with **Embed & Sign**: `RichTextRenderer`, `Contentful`, `AlamofireImage`, and `Alamofire`. From version 0.4.11, `RichTextRenderer` links the other three dynamically instead of containing its own copies, so your app ships exactly one copy of each.

### Your first render

The main entry point for the library is `RichTextViewController`. Use it standalone, or subclass it as shown below. Its `view` hosts a `UITextView` subview backed by a custom `NSLayoutManager`/`NSTextContainer`, so text wraps around embedded views and blockquotes render with the familiar rule-and-indent styling:

```swift
import Contentful
import RichTextRenderer
import UIKit

class ViewController: RichTextViewController {
    private let client = ContentfulService() // Your service fetching data from Contentful.

    init() {
        // Default configuration of the renderer.
        let configuration = DefaultRendererConfiguration()

        let renderer = RichTextDocumentRenderer(configuration: configuration)

        super.init(renderer: renderer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchContent()
    }

    private func fetchContent() {
        client.fetchArticle { [weak self] result in
            switch result {
            case .success(let article):
                self?.richTextDocument = article.content

            case .failure(let error):
                print(error)
            }
        }
    }
}
```

Setting `richTextDocument` triggers rendering automatically — it's safe to set from any thread, since rendering is always dispatched to the main queue.

## Using the SDK

### Renderer configuration

`DefaultRendererConfiguration` provides sane defaults; create an instance and mutate its properties to customize rendering, or provide your own type conforming to `RendererConfiguration`:

```swift
var configuration = DefaultRendererConfiguration()
configuration.contentInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
```

### Rendering views for `ResourceLinkBlock` nodes

Render custom views for block-level embedded entries and assets by passing a view provider to the configuration:

```swift
var configuration = DefaultRendererConfiguration()
configuration.resourceLinkBlockViewProvider = ExampleBlockViewProvider()
```

Below is an example view provider capable of rendering a `Car` model and an image `Asset`:

```swift
import Contentful
import RichTextRenderer
import UIKit

struct ExampleBlockViewProvider: ResourceLinkBlockViewProviding {
    func view(for resource: Link, context: [CodingUserInfoKey: Any]) -> ResourceLinkBlockViewRepresentable? {
        switch resource {
        case .entryDecodable(let entryDecodable):
            if let car = entryDecodable as? Car {
                return CarView(car: car)
            }

            return nil

        case .entry:
            return nil

        case .asset(let asset):
            guard asset.file?.details?.imageInfo != nil else { return nil }

            let imageView = ResourceLinkBlockImageView(asset: asset)
            imageView.backgroundColor = .gray
            imageView.setImageToNaturalHeight()
            return imageView

        default:
            return nil
        }
    }
}

final class CarView: UIView, ResourceLinkBlockViewRepresentable {
    private let car: Car

    var surroundingTextShouldWrap: Bool = false
    var context: [CodingUserInfoKey: Any] = [:]

    init(car: Car) {
        self.car = car
        super.init(frame: .zero)

        let title = UILabel(frame: .zero)
        title.text = "🚗 " + car.model + " 🚗"
        title.translatesAutoresizingMaskIntoConstraints = false
        addSubview(title)

        title.topAnchor.constraint(equalTo: topAnchor).isActive = true
        title.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        title.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        title.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        title.sizeToFit()

        frame = title.bounds
        backgroundColor = .lightGray
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layout(with width: CGFloat) {}
}
```

`ResourceLinkBlockImageView` is a ready-made `ResourceLinkBlockViewRepresentable` for image assets — it loads and caches the image with AlamofireImage and lays itself out to the asset's natural aspect ratio via `setImageToNaturalHeight()`.

### Rendering `ResourceLinkInline` nodes

Inline embedded entries can be rendered as an `NSMutableAttributedString`:

```swift
var configuration = DefaultRendererConfiguration()
configuration.resourceLinkInlineStringProvider = ExampleInlineStringProvider()
```

```swift
import Contentful
import RichTextRenderer
import UIKit

final class ExampleInlineStringProvider: ResourceLinkInlineStringProviding {
    func string(
        for resource: Link,
        context: [CodingUserInfoKey: Any]
    ) -> NSMutableAttributedString {
        switch resource {
        case .entryDecodable(let entryDecodable):
            if let cat = entryDecodable as? Cat {
                return NSMutableAttributedString(
                    string: "🐈 \(cat.name) ❤️",
                    attributes: [.foregroundColor: UIColor.rtrLabel]
                )
            }

        default:
            break
        }

        return NSMutableAttributedString(string: "")
    }
}
```

### Handling hyperlink taps

Intercept taps on plain URL hyperlinks, and on hyperlinks that point to a Contentful entry or asset, via configuration callbacks:

```swift
var configuration = DefaultRendererConfiguration()

configuration.onHyperlinkPressed = { urlString in
    guard let url = URL(string: urlString) else { return }
    UIApplication.shared.open(url)
}

configuration.onResourceHyperlinkPressed = { link in
    switch link {
    case .entry(let entry):
        print("Navigate to entry", entry.sys.id)
    case .asset(let asset):
        print("Navigate to asset", asset.sys.id)
    default:
        break
    }
}
```

### Custom node renderers

Every node type can be rendered with your own logic. Subclass one of the default renderers and attach it to a `DefaultRenderersProvider`:

```swift
final class ExampleParagraphRenderer: ParagraphRenderer {
    override func render(
        node: Paragraph,
        rootRenderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey: Any]
    ) -> [NSMutableAttributedString] {
        // Your code for rendering paragraphs.
    }
}
```

```swift
let configuration = DefaultRendererConfiguration()

var renderersProvider = DefaultRenderersProvider()
renderersProvider.paragraph = ExampleParagraphRenderer()

let renderer = RichTextDocumentRenderer(
    configuration: configuration,
    nodeRenderers: renderersProvider
)

super.init(renderer: renderer)
```

`DefaultRenderersProvider` exposes a renderer property for every node type: `blockQuote`, `heading`, `horizontalRule`, `hyperlink`, `listItem`, `orderedList`, `paragraph`, `resourceLinkBlock`, `resourceLinkInline`, `text`, `unorderedList`, `table`, `tableRow`, `tableRowCell`, and `tableRowHeaderCell`.

### Tables

`Table`, `TableRow`, and table cell nodes render out of the box using `SimpleTableView`. No configuration is required, but you can override `TableRenderer` (and its row/cell counterparts) the same way as any other node renderer if you need a custom table layout.

## Advanced configuration

### Styling text, headings, and lists

`DefaultStyleProvider` supplies fonts and colors for every text variant. Provide your own to customize the base font, monospace font, or hyperlink color:

```swift
let styleProvider = DefaultStyleProvider(
    baseFont: .systemFont(ofSize: 16),
    baseColor: .label,
    monospacedFont: .monospacedSystemFont(ofSize: 15, weight: .regular),
    hyperlinkColor: .systemBlue
)

var configuration = DefaultRendererConfiguration()
configuration.styleProvider = styleProvider
```

For a fully custom typography system, conform to `StyleProviding` directly. `TextConfiguration` controls paragraph and line spacing; `BlockQuoteConfiguration` controls the rule color, width, and text inset of block quotes; `TextListConfiguration` controls indentation of ordered/unordered lists:

```swift
var configuration = DefaultRendererConfiguration()
configuration.textConfiguration = TextConfiguration(paragraphSpacing: 12, lineSpacing: 2)
configuration.blockQuote = BlockQuoteConfiguration(rectangleColor: .systemGray3, rectangleWidth: 4, textInset: 16)
configuration.textList = TextListConfiguration(indentationMultiplier: 18, distanceToListItem: 22)
```

### Dark mode

`UIColor.rtrLabel` and `UIColor.rtrSystemBackground` resolve to `UIColor.label`/`UIColor.systemBackground` on iOS 13+ (falling back to `.black`/`.white` otherwise), and are used as the defaults throughout the library, so rendered content automatically adapts to the user's Light/Dark Mode setting.

### Privacy manifest

The SDK ships [`PrivacyInfo.xcprivacy`](PrivacyInfo.xcprivacy), declaring that it collects no data, performs no tracking, and uses file-timestamp, user-defaults, and system-boot-time APIs only for the reasons Apple permits. When installed via Swift Package Manager or CocoaPods, the manifest is bundled automatically and folds into your app's privacy report.

## Documentation & References

For more information about Rich Text itself, see the [Rich Text concept documentation](https://www.contentful.com/developers/docs/concepts/rich-text/). This library is a companion to [contentful.swift](https://github.com/contentful/contentful.swift); consult its README for details on `Client`, `EntryDecodable`, and fetching content.

### Example applications

The best way to get acquainted with this library is to check out the example apps in this repository:

- [`Example-iOS`](Example-iOS) — a UIKit app demonstrating `RichTextViewController`, block/inline view providers, and custom models.
- [`Example-iOS-SwiftUI`](Example-iOS-SwiftUI) — the same content rendered from SwiftUI via `UIViewControllerRepresentable`.

Pay particular attention to the view provider and inline provider implementations in each example to learn how to render your own entries and assets embedded in rich text.

## Reach out to us

### Have questions about how to use this library?

* Reach out to our community forum: [![Contentful Community Forum](https://img.shields.io/badge/-Join%20Community%20Forum-3AB2E6.svg?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA1MiA1OSI+CiAgPHBhdGggZmlsbD0iI0Y4RTQxOCIgZD0iTTE4IDQxYTE2IDE2IDAgMCAxIDAtMjMgNiA2IDAgMCAwLTktOSAyOSAyOSAwIDAgMCAwIDQxIDYgNiAwIDEgMCA5LTkiIG1hc2s9InVybCgjYikiLz4KICA8cGF0aCBmaWxsPSIjNTZBRUQyIiBkPSJNMTggMThhMTYgMTYgMCAwIDEgMjMgMCA2IDYgMCAxIDAgOS05QTI5IDI5IDAgMCAwIDkgOWE2IDYgMCAwIDAgOSA5Ii8+CiAgPHBhdGggZmlsbD0iI0UwNTM0RSIgZD0iTTQxIDQxYTE2IDE2IDAgMCAxLTIzIDAgNiA2IDAgMSAwLTkgOSAyOSAyOSAwIDAgMCA0MSAwIDYgNiAwIDAgMC05LTkiLz4KICA8cGF0aCBmaWxsPSIjMUQ3OEE0IiBkPSJNMTggMThhNiA2IDAgMSAxLTktOSA2IDYgMCAwIDEgOSA5Ii8+CiAgPHBhdGggZmlsbD0iI0JFNDMzQiIgZD0iTTE4IDUwYTYgNiAwIDEgMS05LTkgNiA2IDAgMCAxIDkgOSIvPgo8L3N2Zz4K&maxAge=31557600)](https://support.contentful.com/)
* Jump into our community slack channel: [![Contentful Community Slack](https://img.shields.io/badge/-Join%20Community%20Slack-2AB27B.svg?logo=slack&maxAge=31557600)](https://www.contentful.com/slack/)

### You found a bug or want to propose a feature?

* File an issue here on GitHub: [![File an issue](https://img.shields.io/badge/-Create%20Issue-6cc644.svg?logo=github&maxAge=31557600)](https://github.com/contentful/rich-text-renderer.swift/issues/new). Make sure to remove any credential from your code before sharing it.

### You need to share confidential information or have other questions?

* File a support ticket at our Contentful Customer Support: [![File support ticket](https://img.shields.io/badge/-Submit%20Support%20Ticket-3AB2E6.svg?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA1MiA1OSI+CiAgPHBhdGggZmlsbD0iI0Y4RTQxOCIgZD0iTTE4IDQxYTE2IDE2IDAgMCAxIDAtMjMgNiA2IDAgMCAwLTktOSAyOSAyOSAwIDAgMCAwIDQxIDYgNiAwIDEgMCA5LTkiIG1hc2s9InVybCgjYikiLz4KICA8cGF0aCBmaWxsPSIjNTZBRUQyIiBkPSJNMTggMThhMTYgMTYgMCAwIDEgMjMgMCA2IDYgMCAxIDAgOS05QTI5IDI5IDAgMCAwIDkgOWE2IDYgMCAwIDAgOSA5Ii8+CiAgPHBhdGggZmlsbD0iI0UwNTM0RSIgZD0iTTQxIDQxYTE2IDE2IDAgMCAxLTIzIDAgNiA2IDAgMSAwLTkgOSAyOSAyOSAwIDAgMCA0MSAwIDYgNiAwIDAgMC05LTkiLz4KICA8cGF0aCBmaWxsPSIjMUQ3OEE0IiBkPSJNMTggMThhNiA2IDAgMSAxLTktOSA2IDYgMCAwIDEgOSA5Ii8+CiAgPHBhdGggZmlsbD0iI0JFNDMzQiIgZD0iTTE4IDUwYTYgNiAwIDEgMS05LTkgNiA2IDAgMCAxIDkgOSIvPgo8L3N2Zz4K&maxAge=31557600)](https://www.contentful.com/support/)

## Get involved

[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?maxAge=31557600)](http://makeapullrequest.com)

We appreciate any help on our repositories. For more details about how to contribute, see the [contributing guide](https://github.com/contentful/contentful.swift/blob/master/Contributing.md) for our Swift SDKs.

## License

This repository is published under the [MIT](LICENSE) license.

## Code of Conduct

We want to provide a safe, inclusive, welcoming, and harassment-free space and experience for all participants, regardless of gender identity and expression, sexual orientation, disability, physical appearance, socioeconomic status, body size, ethnicity, nationality, level of experience, age, religion (or lack thereof), or other identity markers.

[Read our full Code of Conduct](https://github.com/contentful-developer-relations/community-code-of-conduct).
