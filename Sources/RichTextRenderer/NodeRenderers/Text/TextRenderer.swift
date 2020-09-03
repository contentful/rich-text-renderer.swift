// RichTextRenderer

import Contentful
import UIKit

/// Renderer for a `Contentful.Text` node.
open class TextRenderer: NodeRendering {
    public typealias NodeType = Text

    required public init() {}

    open func render(
        node: Text,
        rootRenderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey : Any]
    ) -> [NSMutableAttributedString] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = rootRenderer.configuration.textConfiguration.lineSpacing
        paragraphStyle.paragraphSpacing = rootRenderer.configuration.textConfiguration.paragraphSpacing

        let textColor = UIColor.rtrLabel

        var attributes: [NSAttributedString.Key: Any] = [
            .font: rootRenderer.configuration.fontProvider.font(for: node),
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ]

        if node.marks.contains(Text.Mark(type: .underline)) {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            attributes[.underlineColor] = textColor
        }

        return [
            .init(
                string: node.value,
                attributes: attributes
            )
        ]
    }
}
