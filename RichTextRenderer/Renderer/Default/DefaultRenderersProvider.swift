// RichTextRenderer

public struct DefaultRenderersProvider: NodeRenderersProviding {
    public var heading: NodeRenderer = HeadingRenderer()
    public var text: NodeRenderer = TextRenderer()
    public var orderedList: NodeRenderer = OrderedListRenderer()
    public var unorderedList: NodeRenderer = UnorderedListRenderer()
    public var blockQuote: NodeRenderer = BlockQuoteRenderer()
    public var listItem: NodeRenderer = ListItemRenderer()
    public var paragraph: NodeRenderer = ParagraphRenderer()
    public var hyperlink: NodeRenderer = HyperlinkRenderer()
    public var resourceLinkBlock: NodeRenderer = ResourceLinkBlockRenderer()
    public var resourceLinkInline: NodeRenderer = ResourceLinkInlineRenderer()
    public var horizontalRule: NodeRenderer = HorizontalRuleRenderer()

    public init() {}
}
