// RichTextRenderer

import Contentful
import UIKit

/// A renderer for `Contentful.Paragraph` node.
open class ParagraphRenderer: NodeRendering {
    public typealias NodeType = Paragraph

    required public init() {}

    open func render(
        node: Paragraph,
        rootRenderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey : Any]
    ) -> [NSMutableAttributedString] {
        let contentNodes = node.content.compactMap { $0 as? RenderableNodeProviding }
        var result = contentNodes.reduce(into: [NSMutableAttributedString]()) { result, contentNode in
            let renderedNode = rootRenderer.render(
                node: contentNode,
                context: context
            )

            result.append(contentsOf: renderedNode)
        }

        result.applyListItemStylingIfNecessary(node: node, context: context)
        result.append(.makeNewLineString())

        return result
    }
}
