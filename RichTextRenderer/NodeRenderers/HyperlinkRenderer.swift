// ContentfulRichTextRenderer

import Contentful

/// Renderer for a `Contentful.Hyperlink` node.
public struct HyperlinkRenderer: NodeRenderer {
    public func render(
        node: Node,
        renderer: RichTextRenderer,
        context: [CodingUserInfoKey: Any]
    ) -> [NSMutableAttributedString] {
        guard let hyperlink = node as? Hyperlink else { return [] }

        let attributes: [NSAttributedString.Key: Any] = [
            .link: hyperlink.data.uri
        ]

        let renderedHyperlinkChildren = hyperlink.content.reduce(into: [NSAttributedString]()) { rendered, node in
            if let nodeRenderer = renderer.nodeRenderers.renderer(for: node) {
                let renderedChildren = nodeRenderer.render(node: node, renderer: renderer, context: context)
                rendered.append(contentsOf: renderedChildren)
            }
        }

        let hyperlinkString = renderedHyperlinkChildren.reduce(into: NSMutableAttributedString()) { mutableString, renderedChild in
            mutableString.append(renderedChild)
        }
        hyperlinkString.addAttributes(attributes, range: NSRange(location: 0, length: hyperlinkString.length))
        return [hyperlinkString]
    }
}
