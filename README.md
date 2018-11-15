# Render Contentful Rich Text fields to native strings and views

> **DISCLAIMER:**
>
> This library is experimental. When integrated into an iOS project, this library renders Contentful [RichText](https://www.contentful.com/developers/docs/concepts/rich-text/) to `NSAttributedString` with native `UIView` embedded in the text. This is made possible because this library is built on top of [TextKit](https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/CustomTextProcessing/CustomTextProcessing.html), and provides a powerful plugin system to render Contentful entries and assets that are embedded in `RichText`.
>
> Contentful will not be providing ongoing support for this library, but users are encouraged to create issues, fork and iterate, and collaborate with one another to further development on it. 

**What is Contentful?**

[Contentful](https://www.contentful.com/) provides content infrastructure for digital teams to power websites, apps, and devices. Unlike a CMS, Contentful was built to integrate with the modern software stack. It offers a central hub for structured content, powerful management and delivery APIs, and a customizable web app that enable developers and content creators to ship their products faster.

## Getting started

### Installation

##### CocoaPods installation

```ruby
platform :ios, '9.0'
use_frameworks!
pod 'ContentfulRichTextRenderer'
```

#### Carthage installation

You can also use [Carthage](https://github.com/Carthage/Carthage) for integration by adding the following to your `Cartfile`:

```
github "contentful-labs/rich-text-renderer.swift" ~> 0.0.1
```

#### Swift Package Manager [swift-tools-version 4.2]

Add the following line to your array of dependencies:

```swift
.package(url: "https://github.com/contentful-labs/rich-text-renderer.swift", .upToNextMajor(from: "4.2.0"))
```

### Integrating rich-text-renderer.swift into your app

The main entry point for the library is the `RichTextViewController`. You can either use it standalone, or subclass it. The `view` instance for `RichTextViewController` has a `UITextView` subview that uses a custom `NSLayoutManager` and `NSTextContainer` to lay out text, enabling text to wrap around nested views for embedded assets and entries, and also enabling blockquote styling analogous to that seen on websites. 

Your `RichTextViewController` needs to use a `RenderingConfiguration` instance to infer how various types of rich text nodes should be rendered. This configuration determines what fonts should be used for the various headings and paragraphs, how to style hyperlinks, and how to render nested entries and assets via your custom `ViewProvider` and `InlineProvider`. To render a `RichTextDocument` object, simply set the `richText` property on your view controller instance, either during initialization, or later:

```swift
var styling = RenderingConfiguration()
styling.viewProvider = MyViewProvider()
styling.inlineResourceProvider = MyInlineProvider()
let renderer = DefaultRichTextRenderer(styleConfig: styling)
let viewController = RichTextViewController(richText: yourRichTextField, 
                                            renderer: renderer, 
                                            nibName: nil,
                                            bundle: nil)
```

Initializing a new `RenderingConfiguration()` provides a configuration with sane defaults. Simply create an instance, then mutate it to further customize the rendering.

### Example

The best way to get acquainted with using this library in an iOS app is to check out the [example project code](Example/RendererExample/ViewController.swift). In particular, pay attention to the view provider and inline provider in order to learn how to render entries and assets that are embedded in the rich text.

## Development and contributing

Since Contentful will not be providing top-tier support for this experimental library, please get involved in the development of this project! To get started developing, clone the project, `cd` into the root directory and run `bundle install` to install the correct version of Cocoapods, and other relevant Ruby gems. Then `cd` into the example directory and run `bundle exec pod install`. Since the `Podfile` references the podspec in the parent directory, you can make changes to the pod's source itself, commit them, and make pull-requests.

### Have questions about how to use this library?

* Reach out to our community forum: [![Contentful Community Forum](https://img.shields.io/badge/-Join%20Community%20Forum-3AB2E6.svg?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA1MiA1OSI+CiAgPHBhdGggZmlsbD0iI0Y4RTQxOCIgZD0iTTE4IDQxYTE2IDE2IDAgMCAxIDAtMjMgNiA2IDAgMCAwLTktOSAyOSAyOSAwIDAgMCAwIDQxIDYgNiAwIDEgMCA5LTkiIG1hc2s9InVybCgjYikiLz4KICA8cGF0aCBmaWxsPSIjNTZBRUQyIiBkPSJNMTggMThhMTYgMTYgMCAwIDEgMjMgMCA2IDYgMCAxIDAgOS05QTI5IDI5IDAgMCAwIDkgOWE2IDYgMCAwIDAgOSA5Ii8+CiAgPHBhdGggZmlsbD0iI0UwNTM0RSIgZD0iTTQxIDQxYTE2IDE2IDAgMCAxLTIzIDAgNiA2IDAgMSAwLTkgOSAyOSAyOSAwIDAgMCA0MSAwIDYgNiAwIDAgMC05LTkiLz4KICA8cGF0aCBmaWxsPSIjMUQ3OEE0IiBkPSJNMTggMThhNiA2IDAgMSAxLTktOSA2IDYgMCAwIDEgOSA5Ii8+CiAgPHBhdGggZmlsbD0iI0JFNDMzQiIgZD0iTTE4IDUwYTYgNiAwIDEgMS05LTkgNiA2IDAgMCAxIDkgOSIvPgo8L3N2Zz4K&maxAge=31557600)](https://support.contentful.com/)
* Jump into our community slack channel: [![Contentful Community Slack](https://img.shields.io/badge/-Join%20Community%20Slack-2AB27B.svg?logo=slack&maxAge=31557600)](https://www.contentful.com/slack/)

## License

This repository is published under the [MIT](LICENSE) license.

## Code of Conduct

We want to provide a safe, inclusive, welcoming, and harassment-free space and experience for all participants, regardless of gender identity and expression, sexual orientation, disability, physical appearance, socioeconomic status, body size, ethnicity, nationality, level of experience, age, religion (or lack thereof), or other identity markers.

[Read our full Code of Conduct](https://github.com/contentful-developer-relations/community-code-of-conduct).

