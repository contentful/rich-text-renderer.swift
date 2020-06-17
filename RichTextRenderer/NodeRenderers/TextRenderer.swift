// RichTextRenderer

import Contentful
import UIKit

/// Renderer for a `Contentful.Text` node.
public struct TextRenderer: NodeRenderer {
    public func render(
        node: Node,
        renderer: RichTextRenderer,
        context: [CodingUserInfoKey: Any]
    ) -> [NSMutableAttributedString] {
        guard let text = node as? Text else { return [] }

        let paragraphStyle = MutableParagraphStyle()
        paragraphStyle.lineSpacing = renderer.configuration.textConfiguration.lineSpacing
        paragraphStyle.paragraphSpacing = renderer.configuration.textConfiguration.paragraphSpacing

        var attributes: [NSAttributedString.Key: Any] = [
            .font: renderer.configuration.fontProvider.font(for: text),
            .paragraphStyle: paragraphStyle
        ]

        if text.marks.contains(Text.Mark(type: .underline)) {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }

        return [
            .init(
                string: text.value,
                attributes: attributes
            )
        ]
    }
}
