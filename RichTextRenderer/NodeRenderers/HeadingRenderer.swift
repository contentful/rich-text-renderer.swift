// RichTextRenderer

import Contentful

/// Renderer for a `Contentful.Heading` node.
public struct HeadingRenderer: NodeRenderer {

    public func render(
        node: Node,
        renderer: RichTextRenderer,
        context: [CodingUserInfoKey: Any]
    ) -> [NSMutableAttributedString] {
        let heading = node as! Heading
        
        var rendered = heading.content.reduce(into: [NSMutableAttributedString]()) { (rendered, node) in
            let nodeRenderer = renderer.renderer(for: node)
            let renderedChildren = nodeRenderer.render(node: node, renderer: renderer, context: context)
            rendered.append(contentsOf: renderedChildren)
        }

        rendered.forEach {
            let headingLevel = HeadingLevel(rawValue: Int(heading.level)) ?? HeadingLevel.h1
            let font = renderer.configuration.heading.fonts.font(for: headingLevel)
            $0.addAttributes([.font: font], range: NSRange(location: 0, length: $0.length))
        }
        rendered.applyListItemStylingIfNecessary(node: node, context: context)
        rendered.appendNewlineIfNecessary(node: node)
        return rendered
    }
}
