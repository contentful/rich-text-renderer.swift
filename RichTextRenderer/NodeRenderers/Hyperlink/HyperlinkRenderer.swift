// RichTextRenderer

import Contentful

/// Renderer for a `Contentful.Hyperlink` node.
open class HyperlinkRenderer: NodeRendering {
    public typealias NodeType = Hyperlink

    required public init() {}

    open func render(
        node: Hyperlink,
        rootRenderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey : Any]
    ) -> [NSMutableAttributedString] {
        let contentNodes = node.content.compactMap { $0 as? RenderableNodeProviding }
        let result = contentNodes.reduce(into: [NSAttributedString]()) { result, contentNode in
            let renderedNode = rootRenderer.render(
                node: contentNode,
                context: context
            )

            result.append(contentsOf: renderedNode)
        }.reduce(into: NSMutableAttributedString()) { result, child in
            result.append(child)
        }

        result.addAttributes(
            [.link: node.data.uri],
            range: result.fullRange
        )

        return [result]
    }
}
