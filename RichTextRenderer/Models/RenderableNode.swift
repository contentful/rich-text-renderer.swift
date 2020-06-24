// RichTextRenderer

import Contentful

/// Concrete types representing renderable nodes.
public enum RenderableNode {
    case blockQuote(BlockQuote)
    case heading(Heading)
    case horizontalRule(HorizontalRule)
    case hyperlink(Hyperlink)
    case listItem(ListItem)
    case orderedList(OrderedList)
    case paragraph(Paragraph)
    case resourceLinkBlock(ResourceLinkBlock)
    case resourceLinkInline(ResourceLinkInline)
    case text(Text)
    case unorderedList(UnorderedList)
}
