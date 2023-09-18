// RichTextRenderer

import UIKit
import Contentful

/// Default configuration for the `RichTextRenderer`.
public struct DefaultRendererConfiguration: RendererConfiguration {
    
    public var styleProvider: StyleProviding = DefaultStyleProvider()
    public var contentInsets: UIEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 15)
    public var textConfiguration: TextConfiguration = .default
    public var blockQuote: BlockQuoteConfiguration = .default
    public var textList: TextListConfiguration = .default
    public var horizontalRuleViewProvider: HorizontalRuleViewProviding = HorizontalRuleViewProvider()
    public var resourceLinkInlineStringProvider: ResourceLinkInlineStringProviding? = nil
    public var resourceLinkBlockViewProvider: ResourceLinkBlockViewProviding? = nil
    public var onResourceHyperlinkPressed: ((Contentful.Link) -> Void)?
    public var onHyperlinkPressed: ((String) -> Void)?

    public init() {}
}
