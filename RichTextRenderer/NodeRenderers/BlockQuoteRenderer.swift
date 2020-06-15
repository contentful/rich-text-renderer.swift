// RichTextRenderer

import Contentful

/// Renderer for a `Contentful.BlockQuote` node.
public struct BlockQuoteRenderer: NodeRenderer {
    public func render(
        node: Node,
        renderer: RichTextRenderer,
        context: [CodingUserInfoKey: Any]
    ) -> [NSMutableAttributedString] {
        let blockQuote = node as! BlockQuote

        let renderedChildren = blockQuote.content.reduce(into: [NSMutableAttributedString]()) { rendered, node in
            let nodeRenderer = renderer.renderer(for: node)
            let renderedChildren = nodeRenderer.render(node: node, renderer: renderer, context: context)
            rendered.append(contentsOf: renderedChildren)
        }

        let quoteString = renderedChildren.reduce(into: NSMutableAttributedString()) { mutableString, renderedChild in
            mutableString.append(renderedChild)
        }

        let attributes: [NSAttributedString.Key: Any] = [.block: true]

        quoteString.addAttributes(
            attributes,
            range: NSRange(location: 0, length: quoteString.length)
        )

        var rendered = [quoteString]
        rendered.applyListItemStylingIfNecessary(node: node, context: context)
        rendered.appendNewlineIfNecessary(node: node)
        return rendered
    }
}
