// RichTextRenderer

public struct DefaultRenderersProvider: NodeRenderersProviding {
    public var blockQuote: BlockQuoteRenderer = BlockQuoteRenderer()
    public var heading: HeadingRenderer = HeadingRenderer()
    public var horizontalRule: HorizontalRuleRenderer = HorizontalRuleRenderer()
    public var hyperlink: HyperlinkRenderer = HyperlinkRenderer()
    public var listItem: ListItemRenderer = ListItemRenderer()
    public var orderedList: OrderedListRenderer = OrderedListRenderer()
    public var paragraph: ParagraphRenderer = ParagraphRenderer()
    public var resourceLinkBlock: ResourceLinkBlockRenderer = ResourceLinkBlockRenderer()
    public var resourceLinkInline: ResourceLinkInlineRenderer = ResourceLinkInlineRenderer()
    public var text: TextRenderer = TextRenderer()
    public var unorderedList: UnorderedListRenderer = UnorderedListRenderer()

    public init() {}
}
