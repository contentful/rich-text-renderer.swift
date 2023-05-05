# Render Contentful Rich Text fields to native strings and views
When integrated into an iOS project, this library renders Contentful [RichText](https://www.contentful.com/developers/docs/concepts/rich-text/) to `NSAttributedString` with native `UIView` embedded in the text. This is made possible because this library is built on top of [TextKit](https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/CustomTextProcessing/CustomTextProcessing.html), and provides a powerful plugin system to render Contentful entries and assets that are embedded in `RichText`.

**What is Contentful?**

[Contentful](https://www.contentful.com/) provides content infrastructure for digital teams to power websites, apps, and devices. Unlike a CMS, Contentful was built to integrate with the modern software stack. It offers a central hub for structured content, powerful management and delivery APIs, and a customizable web app that enable developers and content creators to ship their products faster.

## Getting started

### Installation

##### CocoaPods installation

```ruby
platform :ios, '11.0'
use_frameworks!
pod 'ContentfulRichTextRenderer'
```

##### Carthage installation
You can also use [Carthage](https://github.com/Carthage/Carthage) for integration by adding the following to your `Cartfile`:

```
github "contentful/contentful.swift"
github "Alamofire/AlamofireImage"
github "contentful/rich-text-renderer.swift"
```

And then run the following command in the terminal:

```
carthage update --platform iOS --use-xcframeworks
```

Add all the XCFrameworks from `Cartfile/Build` directory into your project manually.

### Integrating the renderer into your 
The main entry point for the library is the `RichTextViewController`. You can either use it standalone, or subclass it. The `view` instance for `RichTextViewController` has a `UITextView` subview that uses a custom `NSLayoutManager` and `NSTextContainer` to lay out text, enabling text to wrap around nested views for embedded assets and entries, and also enabling blockquote styling analogous to that seen on websites. 

```swift
  import Contentful
  import RichTextRenderer
  import UIKit

  class ViewController: RichTextViewController {
      private let client = ContentfulService() /// Your service fetching data from Contentful.

      init() {
          /// Default configuration of the renderer.
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
                  break
              }
          }
      }
  }
```

You can configure how the renderer renders content by modifying `DefaultRendererConfiguration` instance or by creating new one conforming to `RendererConfiguration` protocol.

Initializing instance of `DefaultRendererConfiguration` provides a configuration with sane defaults. Simply create an instance, then mutate it to further customize the rendering.

### Rendering view for `ResourceLinkBlock` node.
You can render custom views for `ResourceLinkBlock` nodes by passing a view provider to the configuration object.

```swift
  var configuration = DefaultRendererConfiguration()
  configuration.resourceLinkBlockViewProvider = ExampleBlockViewProvider()
```

Below is the example implementation on the view provider that is cappable of rendering `Car` model and the `Asset`.

```swift
  struct ExampleViewProvider: ResourceLinkBlockViewProviding {
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
      var context: [CodingUserInfoKey : Any] = [:]

      public init(car: Car) {
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

### Rendering `ResourceLinkInline` node.
Inline elements in the `RichTextDocument` can be rendered as `NSMutableAttributedString` object. 

```swift
  var configuration = DefaultRendererConfiguration()
  configuration.resourceLinkInlineStringProvider = ExampleInlineStringProvider()
```

Below is the implementation of the inline string provider that renders `Cat` type.

```swift
  import Contentful
  import RichTextRenderer
  import UIKit

  final class ExampleInlineStringProvider: ResourceLinkInlineStringProviding {
      func string(
          for resource: Link,
          context: [CodingUserInfoKey : Any]
      ) -> NSMutableAttributedString {
          switch resource {
          case .entryDecodable(let entryDecodable):
              if let cat = entryDecodable as? Cat {
                  return CatInlineProvider.string(for: cat)
              }

          default:
              break
          }

          return NSMutableAttributedString(string: "")
      }
  }

  private final class CatInlineProvider {
      static func string(for cat: Cat) -> NSMutableAttributedString {
          return NSMutableAttributedString(
              string: "🐈 \(cat.name) ❤️",
              attributes: [
                  .foregroundColor: UIColor.rtrLabel
              ]
          )
      }
  }
```

### Custom renderers
The library has been implemented the way that you can provide custom renderers for specific node types.

Simply create a class that inherits from one of the default renderers and write your own. Then attach to a `DefaultRenderersProvider` and that's it.

```swift
final class ExampleParagraphRenderer: ParagraphRenderer {
  typealias NodeType = Paragraph

  override func render(
      node: Paragraph,
      rootRenderer: RichTextDocumentRendering,
      context: [CodingUserInfoKey : Any]
  ) -> [NSMutableAttributedString] {
      /// Your code for rendering paragraphs.
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

### Example Usage
The best way to get acquainted with using this library in an iOS app is to check out the example that is a part of this repository. In particular, pay attention to the view provider and inline provider in order to learn how to render entries and assets that are embedded in the rich text.

### Have questions about how to use this library?
* Reach out to our community forum: [![Contentful Community Forum](https://img.shields.io/badge/-Join%20Community%20Forum-3AB2E6.svg?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA1MiA1OSI+CiAgPHBhdGggZmlsbD0iI0Y4RTQxOCIgZD0iTTE4IDQxYTE2IDE2IDAgMCAxIDAtMjMgNiA2IDAgMCAwLTktOSAyOSAyOSAwIDAgMCAwIDQxIDYgNiAwIDEgMCA5LTkiIG1hc2s9InVybCgjYikiLz4KICA8cGF0aCBmaWxsPSIjNTZBRUQyIiBkPSJNMTggMThhMTYgMTYgMCAwIDEgMjMgMCA2IDYgMCAxIDAgOS05QTI5IDI5IDAgMCAwIDkgOWE2IDYgMCAwIDAgOSA5Ii8+CiAgPHBhdGggZmlsbD0iI0UwNTM0RSIgZD0iTTQxIDQxYTE2IDE2IDAgMCAxLTIzIDAgNiA2IDAgMSAwLTkgOSAyOSAyOSAwIDAgMCA0MSAwIDYgNiAwIDAgMC05LTkiLz4KICA8cGF0aCBmaWxsPSIjMUQ3OEE0IiBkPSJNMTggMThhNiA2IDAgMSAxLTktOSA2IDYgMCAwIDEgOSA5Ii8+CiAgPHBhdGggZmlsbD0iI0JFNDMzQiIgZD0iTTE4IDUwYTYgNiAwIDEgMS05LTkgNiA2IDAgMCAxIDkgOSIvPgo8L3N2Zz4K&maxAge=31557600)](https://support.contentful.com/)
* Jump into our community slack channel: [![Contentful Community Slack](https://img.shields.io/badge/-Join%20Community%20Slack-2AB27B.svg?logo=slack&maxAge=31557600)](https://www.contentful.com/slack/)

## License
This repository is published under the [MIT](LICENSE) license.

## Code of Conduct
We want to provide a safe, inclusive, welcoming, and harassment-free space and experience for all participants, regardless of gender identity and expression, sexual orientation, disability, physical appearance, socioeconomic status, body size, ethnicity, nationality, level of experience, age, religion (or lack thereof), or other identity markers.

[Read our full Code of Conduct](https://github.com/contentful-developer-relations/community-code-of-conduct).

