// RichTextRenderer

import Contentful

/// Renderer for a `Contentful.Heading` node.
open class HeadingRenderer: NodeRendering {
    public typealias NodeType = Heading

    public func render(
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
            let font = rootRenderer.configuration.fontProvider.headingFonts.font(for: node.headingLevel)
            $0.addAttributes([.font: font], range: $0.fullRange)
        }
        result.applyListItemStylingIfNecessary(node: node, context: context)
        result.append(.makeNewLineString())

        return result
    }
}
