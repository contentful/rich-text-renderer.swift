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

        let currentFont = rootRenderer.configuration.fontProvider.font(for: node)
                
        var attributes: [NSAttributedString.Key: Any] = [
            .font: currentFont,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ]

        if node.marks.contains(Text.Mark(type: .underline)) {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            attributes[.underlineColor] = textColor
        }
        
        let hasSubscript = node.marks.contains(Text.Mark(type: .subscript))
        let hasSuperscript = node.marks.contains(Text.Mark(type: .superscript))
        
        if hasSuperscript || hasSubscript {
            // We make the superscript/subscript font twice smaller than original
            let twiceSmallerFont = currentFont.withSize(currentFont.pointSize * 0.5)
            attributes[.font] = twiceSmallerFont
            // We also need to move superscript up and subscript down by the size of the new font
            let multiplier: CGFloat = hasSuperscript ? 1 : -1
            attributes[.baselineOffset] = twiceSmallerFont.pointSize * multiplier
        }

        return [
            .init(
                string: node.value,
                attributes: attributes
            )
        ]
    }
}
