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
            let headingLevel = HeadingLevel(rawValue: Int(node.level)) ?? HeadingLevel.h1
            let font = rootRenderer.configuration.heading.fonts.font(for: headingLevel)
            $0.addAttributes([.font: font], range: NSRange(location: 0, length: $0.length))
        }
        result.applyListItemStylingIfNecessary(node: node, context: context)
        result.appendNewlineIfNecessary(node: node)

        return result
    }
}
