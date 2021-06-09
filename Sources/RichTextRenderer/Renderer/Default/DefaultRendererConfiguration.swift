// RichTextRenderer

import UIKit

/// Default configuration for the `RichTextRenderer`.
public struct DefaultRendererConfiguration: RendererConfiguration {
    public var fontProvider: FontProviding
    public var contentInsets: UIEdgeInsets
    public var textConfiguration: TextConfiguration
    public var blockQuote: BlockQuoteConfiguration
    public var textList: TextListConfiguration
    public var horizontalRuleViewProvider: HorizontalRuleViewProviding
    public var resourceLinkInlineStringProvider: ResourceLinkInlineStringProviding?
    public var resourceLinkBlockViewProvider: ResourceLinkBlockViewProviding?
    public var imageLoader: ImageLoader

    public init(
        fontProvider: FontProviding = DefaultFontProvider(),
        contentInsets: UIEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 15),
        textConfiguration: TextConfiguration = .default,
        blockQuote: BlockQuoteConfiguration = .default,
        textList: TextListConfiguration = .default,
        horizontalRuleViewProvider: HorizontalRuleViewProviding = HorizontalRuleViewProvider(),
        resourceLinkInlineStringProvider: ResourceLinkInlineStringProviding? = nil,
        resourceLinkBlockViewProvider: ResourceLinkBlockViewProviding? = nil,
        imageLoader: ImageLoader = URLSessionImageLoader()
    ) {
        self.fontProvider = fontProvider
        self.contentInsets = contentInsets
        self.textConfiguration = textConfiguration
        self.blockQuote = blockQuote
        self.textList = textList
        self.horizontalRuleViewProvider = horizontalRuleViewProvider
        self.resourceLinkInlineStringProvider = resourceLinkInlineStringProvider
        self.resourceLinkBlockViewProvider = resourceLinkBlockViewProvider
        self.imageLoader = imageLoader
    }
}
