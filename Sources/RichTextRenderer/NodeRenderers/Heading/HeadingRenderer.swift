// RichTextRenderer

import Contentful
import UIKit

/// Renderer for a `Contentful.Heading` node.
open class HeadingRenderer: NodeRendering {
    public typealias NodeType = Heading

    required public init() {}

    open func render(
        node: Heading,
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

        result.forEach {
            let font = rootRenderer.configuration.styleProvider.headingStyles.font(for: node.headingLevel)
            let color = rootRenderer.configuration.styleProvider.headingStyles.color(for: node.headingLevel)
            $0.addAttributes([.font: font, .foregroundColor: color], range: $0.fullRange)
        }
        result.applyListItemStylingIfNecessary(node: node, context: context)
        result.append(.makeNewLineString())

        return result
    }
}
