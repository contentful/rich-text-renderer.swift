// RichTextRenderer

import Contentful
import CoreGraphics

/// A `RenderingConfiguration` describes all the configuration that should be used to render a `RichTextDocument`
/// with a `RichTextRenderer`.
public struct RendererConfiguration {

    public init() {}

    /// An instance of `RenderingConfiguration` with all variables set to defaults.
    public static let `default` = RendererConfiguration()

    /// Provides fonts in different variations for the renderers.
    public var fontProvider: FontProviding = DefaultFontProvider()

    /// The margin from the leading edge with which embeddedd views for `ResourceLinkBlock` nodes should be inset.
    /// Defaults to 10.0 points.
    public var embedMargin: CGFloat = 10.0

    /// Configuration for `Text` nodes.
    public var textConfiguration: TextConfiguration = .default

    /// Configuration for `BlockQuote` nodes.
    public var blockQuote: BlockQuoteConfiguration = .default

    /// Configuration for `Heading` nodes.
    public var heading: HeadingConfiguration = .default

    /// Configuration for text lists.
    public var textList: TextListConfiguration = .default

    /// Provides a view for `HorizontalRule` node.
    public var horizontalRuleViewProvider: HorizontalRuleViewProviding = HorizontalRuleViewProvider()

    /// Provides a string for `ResourceLinkInline` nodes.
    public var resourceLinkInlineStringProvider: ResourceLinkInlineStringProviding
        = EmptyResourceLinkInlineStringProvider()

    /// Provides a view for `ResourceLinkBlock` nodes.
    public var resourceLinkBlockViewProvider: ResourceLinkBlockViewProviding
        = EmptyResourceLinkBlockViewProvider()
}
