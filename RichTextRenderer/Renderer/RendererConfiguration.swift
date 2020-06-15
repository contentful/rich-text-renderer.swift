// RichTextRenderer

import Contentful
import CoreGraphics

/// Describes configuration of the `RichTextRenderer`.
public protocol RendererConfiguration {

    /// Provides fonts in different variations for the renderers.
    var fontProvider: FontProviding { get }

    /**
     The margin from the leading edge with which embeddedd views for `ResourceLinkBlock` nodes should be inset.
     Defaults to 10.0 points.
     */
    var embedMargin: CGFloat { get }

    /// Configuration for `Text` nodes.
    var textConfiguration: TextConfiguration { get }

    /// Configuration for `BlockQuote` nodes.
    var blockQuote: BlockQuoteConfiguration { get }

    /// Configuration for `Heading` nodes.
    var heading: HeadingConfiguration { get }

    /// Configuration for text lists.
    var textList: TextListConfiguration { get }

    /// Provides a view for `HorizontalRule` node.
    var horizontalRuleViewProvider: HorizontalRuleViewProviding { get }

    /// Provides a string for `ResourceLinkInline` nodes.
    var resourceLinkInlineStringProvider: ResourceLinkInlineStringProviding? { get }

    /// Provides a view for `ResourceLinkBlock` nodes.
    var resourceLinkBlockViewProvider: ResourceLinkBlockViewProviding? { get }
}
