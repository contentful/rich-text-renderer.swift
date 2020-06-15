// RichTextRenderer

import Contentful

/// Renderer for a `Contentful.Text` node.
public struct TextRenderer: NodeRenderer {
    public func render(
        node: Node,
        renderer: RichTextRenderer,
        context: [CodingUserInfoKey: Any]
    ) -> [NSMutableAttributedString] {
        let text = node as! Text

        let paragraphStyle = MutableParagraphStyle()
        paragraphStyle.lineSpacing = renderer.configuration.textConfiguration.lineSpacing
        paragraphStyle.paragraphSpacing = renderer.configuration.textConfiguration.paragraphSpacing

        return [
            .init(
                string: text.value,
                attributes: [
                    .font: renderer.configuration.fontProvider.font(for: text),
                    .paragraphStyle: paragraphStyle
                ]
            )
        ]
    }
}
