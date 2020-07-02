// RichTextRenderer

import Contentful
import UIKit

/// Renderer for a `Contentful.Text` node.
open class TextRenderer: NodeRendering {
    public typealias NodeType = Text

    public func render(
        node: Text,
        rootRenderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey : Any]
    ) -> [NSMutableAttributedString] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = rootRenderer.configuration.textConfiguration.lineSpacing
        paragraphStyle.paragraphSpacing = rootRenderer.configuration.textConfiguration.paragraphSpacing

        var attributes: [NSAttributedString.Key: Any] = [
            .font: rootRenderer.configuration.fontProvider.font(for: node),
            .paragraphStyle: paragraphStyle
        ]

        if node.marks.contains(Text.Mark(type: .underline)) {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }

        return [
            .init(
                string: node.value,
                attributes: attributes
            )
        ]
    }
}
