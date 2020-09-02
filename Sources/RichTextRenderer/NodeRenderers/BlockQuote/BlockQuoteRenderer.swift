// RichTextRenderer

import Contentful
import UIKit

/// Renderer for a `Contentful.BlockQuote` node.
open class BlockQuoteRenderer: NodeRendering {
    public typealias NodeType = BlockQuote

    required public init() {}

    open func render(
        node: BlockQuote,
        rootRenderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey : Any]
    ) -> [NSMutableAttributedString] {
        let contentNodes = node.content.compactMap { $0 as? RenderableNodeProviding }
        let result = contentNodes.reduce(into: [NSMutableAttributedString()]) { result, contentNode in
            let renderedNode = rootRenderer.render(
                node: contentNode,
                context: context
            )
            result.append(contentsOf: renderedNode)

        }.reduce(into: NSMutableAttributedString()) { result, child in
            result.append(child)
        }

        result.addAttributes(
            [.block: true],
            range: result.fullRange
        )

        var rendered = [result]
        rendered.applyListItemStylingIfNecessary(node: node, context: context)
        rendered.append(.makeNewLineString())
        return rendered
    }
}
