// RichTextRenderer

import CoreGraphics

/// Default configuration for the `RichTextRenderer`.
public struct DefaultRendererConfiguration: RendererConfiguration {
    public var fontProvider: FontProviding = DefaultFontProvider()
    public var embedMargin: CGFloat = 10.0
    public var textConfiguration: TextConfiguration = .default
    public var blockQuote: BlockQuoteConfiguration = .default
    public var heading: HeadingConfiguration = .default
    public var textList: TextListConfiguration = .default
    public var horizontalRuleViewProvider: HorizontalRuleViewProviding = HorizontalRuleViewProvider()
    public var resourceLinkInlineStringProvider: ResourceLinkInlineStringProviding? = nil
    public var resourceLinkBlockViewProvider: ResourceLinkBlockViewProviding? = nil

    public init() {}
}
