// RichTextRenderer

import Contentful
import UIKit

/// Describes configuration of the `RichTextRenderer`.
public protocol RendererConfiguration {
    /// Provides fonts in different variations for the renderers.
    var styleProvider: StyleProviding { get }

    /// Insets of the rendered content
    var contentInsets: UIEdgeInsets { get }

    /// Configuration for `Text` nodes.
    var textConfiguration: TextConfiguration { get }

    /// Configuration for `BlockQuote` nodes.
    var blockQuote: BlockQuoteConfiguration { get }

    /// Configuration for text lists.
    var textList: TextListConfiguration { get }

    /// Provides a view for `HorizontalRule` node.
    var horizontalRuleViewProvider: HorizontalRuleViewProviding { get }

    /// Provides a string for `ResourceLinkInline` nodes.
    var resourceLinkInlineStringProvider: ResourceLinkInlineStringProviding? { get }

    /// Provides a view for `ResourceLinkBlock` nodes.
    var resourceLinkBlockViewProvider: ResourceLinkBlockViewProviding? { get }
    
    /// Called, when an asset or entry hyperlink is pressed
    var onResourceHyperlinkPressed: ((_ destination: Link) -> Void)? { get }
}
