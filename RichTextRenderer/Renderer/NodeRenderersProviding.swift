// RichTextRenderer

import Contentful

public protocol NodeRenderersProviding {

    var blockQuote: BlockQuoteRenderer { get set }
    var heading: HeadingRenderer { get set }
    var horizontalRule: HorizontalRuleRenderer { get set }
    var hyperlink: HyperlinkRenderer { get set }
    var listItem: ListItemRenderer { get set }
    var orderedList: OrderedListRenderer { get set }
    var paragraph: ParagraphRenderer { get set }
    var resourceLinkBlock: ResourceLinkBlockRenderer { get set }
    var resourceLinkInline: ResourceLinkInlineRenderer { get set }
    var text: TextRenderer { get set }
    var unorderedList: UnorderedListRenderer { get set }

    func render(
        node: RenderableNode,
        renderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey: Any]
    ) -> [NSMutableAttributedString]
}

extension NodeRenderersProviding {
    public func render(
        node: RenderableNode,
        renderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey : Any]
    ) -> [NSMutableAttributedString] {
        switch node {
        case .blockQuote(let blockQuote):
            return self.blockQuote.render(
                node: blockQuote,
                rootRenderer: renderer,
                context: context
            )

        case .heading(let heading):
            return self.heading.render(
                node: heading,
                rootRenderer: renderer,
                context: context
            )

        case .horizontalRule(let horizontalRule):
            return self.horizontalRule.render(
                node: horizontalRule,
                rootRenderer: renderer,
                context: context
            )

        case .hyperlink(let hyperlink):
            return self.hyperlink.render(
                node: hyperlink,
                rootRenderer: renderer,
                context: context
            )

        case .listItem(let listItem):
            return self.listItem.render(
                node: listItem,
                rootRenderer: renderer,
                context: context
            )

        case .orderedList(let orderedList):
            return self.orderedList.render(
                node: orderedList,
                rootRenderer: renderer,
                context: context
            )

        case .paragraph(let paragraph):
            return self.paragraph.render(
                node: paragraph,
                rootRenderer: renderer,
                context: context
            )

        case .resourceLinkBlock(let resourceLinkBlock):
            return self.resourceLinkBlock.render(
                node: resourceLinkBlock,
                rootRenderer: renderer,
                context: context
            )

        case .resourceLinkInline(let resourceLinkInline):
            return self.resourceLinkInline.render(
                node: resourceLinkInline,
                rootRenderer: renderer,
                context: context
            )

        case .text(let text):
            return self.text.render(
                node: text,
                rootRenderer: renderer,
                context: context
            )

        case .unorderedList(let unorderedList):
            return self.unorderedList.render(
                node: unorderedList,
                rootRenderer: renderer,
                context: context
            )
        }
    }
}
