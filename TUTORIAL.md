# Integrating rich-text-renderer.swift into an iOS app

## The minimum configuration

The main entry point for the library is the `RichTextViewController`. You can either use it standalone, or subclass it. The `view` instance for `RichTextViewController` has a `UITextView` subview that uses a custom `NSLayoutManager` and `NSTextContainer` to lay out text, enabling text to wrap around nested views for embedded assets and entries, and also enabling blockquote styling analogous to that seen on websites. 

## The minimum configuring for RichTextViewController

`RichTextViewController` needs to use a `RenderingConfiguration` instance to infer how various types of rich text nodes should be rendered. This configuration determines what fonts should be used for the various headings and paragraphs, how to style hyperlinks, and how to render nested entries and assets via your custom `ViewProvider` and `InlineProvider` instances. Initializing a new `RenderingConfiguration()` provides a configuration with sane defaults. Simply create an instance, then mutate it to further customize the rendering.

To render rich text, the minimum requirement is to initialize an instance that conforms `RichTextRenderer` to pass to your instance of `RichTextViewController`. The rendering library provides a default renderer, `DefaultRichTextRenderer`, configured to use pre-configured renderers for each node type. The below code is an example of a very basic configuration.

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

### Rendering custom views for embedded entries and assets

If you do not poplulate the `viewProvider` or `inlineResourceProvider` properties of the rendering configuration structure, an empty view with a frame of `CGRect.zero` will be rendered for embedded entries and assets, and an empty string will be rendered for inline & hyperlink entries and assets. In order to customize the rendering for entries and assets that have been inlined, hyperlinked, or embedded into a rich text document, custom types conforming to `ViewProvider` and `InlineProvider` must be attached to the instance of `RenderingConfiguration` that is being used. Both protocols only require one method for conformance.

```swift
public protocol InlineProvider {
    func string(for resource: FlatResource, context: [CodingUserInfoKey: Any]) -> NSMutableAttributedString
}

public protocol ViewProvider {
    /// This function should return the view which will be rendered for a `Contentful.ResourceLinkBlock` node.
    func view(for resource: FlatResource, context: [CodingUserInfoKey: Any]) -> ResourceBlockView
}
```

The function for `ViewProvider` requires that you return a `ResourceBlockView` rather than a simple `UIView`. `ResourceBlockView` is declared as a union type of `UIView` and `ResourceLinkBlockRepresentable`. The reason for this union type is that views corresponding to embedded entries and assets must be able to resize themselves according to the content inside and the width provided given the space in the rich text's superview. You can require that views span the entire width of the superview, or that text wraps around those views by setting the `surroundingTextShouldWrap` property. The declarations of `ResourceBlockView` and `ResourceLinkBlockRepresentable` are below.

```swift
/// A union type that bridges the current operating system's view-type with `ResourceLinkBlockRepresentable`.
public typealias ResourceBlockView = ResourceLinkBlockRepresentable & View

/// Views should conform to this protocol so that `ResourceLinkBlockRenderer` instances can apply the
/// correct `NSAttributedString.Key`, view pairs to the range of characters which comprise a `Contentful.ResourceLinkBlock` node.
public protocol ResourceLinkBlockRepresentable {

    /// This boolean determines if text should wrap along the sides of this view (if that view doesn't stretch the width of the superview),
    /// or if text should continue below.
    var surroundingTextShouldWrap: Bool { get }

    /// The passed-in context, useful for determining your own rendering logic.
    var context: [CodingUserInfoKey: Any] { get set }

    /// This method is called by `RichTextViewController` and is passed a width value which represents the
    /// available width within the superview. Implementing this method is useful for applying the proper height to the view based on its width.
    func layout(with width: CGFloat)
}
```

## Writing custom renderers

While initializing a new `DefaultRichTextRenderer` structure provides sane default renderers for all node types, there may be scenarios where it is preferable to completely override a renderer for a specific node type. All node renderers conform to the node renderer protocol:

```swift
public protocol NodeRenderer {
    /// Method to render a node. This method is called by instances of `RichTextRenderer` to delegate
    /// node rendering to the correct renderer for a given node.
    func render(node: Node, renderer: RichTextRenderer, context: [CodingUserInfoKey: Any]) -> [NSMutableAttributedString]
}
```

Once you have implemented a renderer, for instance a `CustomHeadingRenderer: NodeRenderer`, then simply set the relevant property to use your custom renderer instead of the default:

```swift
var styling = RenderingConfiguration()
styling.viewProvider = MyViewProvider()
styling.inlineResourceProvider = MyInlineProvider()
var renderer = DefaultRichTextRenderer(styleConfig: styling)
renderer.headingRenderer = CustomHeadingRenderer() // override the heading renderer here
```

To get an idea of how to implement a `NodeRenderer`, check out the source code for the renderers provided by the library.

Once your instance of `RichTextRenderer`, either a fully custom type, or a `DefaultRichTextRenderer` structure that has been customized, pass it to `RichTextViewController`.

## Triggering the rendering cycle

To render a `RichTextDocument` object, simply set the `richText` property on your view controller instance, either during initialization, or later:

During initialization:

```swift
let viewController = RichTextViewController(richText: yourRichTextField, 
                                            renderer: renderer, 
                                            nibName: nil,
                                            bundle: nil)
```

or after initialization:

```
let viewController = RichTextViewController(richText: nil, 
                                            renderer: renderer, 
                                            nibName: nil,
                                            bundle: nil)
parentViewController.present(viewController, animated: true, completion: nil)
viewController.richText = richTextDocumentInstance
```

Please note that if the rich text is set after the view has been shown on screen, that no special loading state is rendered by default. It is up to you to render any other subviews based on state.
