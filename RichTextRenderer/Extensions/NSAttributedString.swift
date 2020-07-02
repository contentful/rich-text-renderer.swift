//
//  NSAttributedString.swift
//  ContentfulRichTextRenderer
//
//  Created by JP Wright on 01/10/18.
//

import Foundation
import Contentful
import UIKit

internal extension NSMutableAttributedString {

    /// This method uses all the state passed-in via the `context` to apply the proper paragraph styling
    /// to the characters contained in the passed-in node.
    func applyListItemStyling(node: Node, context: [CodingUserInfoKey: Any]) {
        guard let listContext = context[.listContext] as? ListContext else { return }

        let renderingConfig = context.rendererConfiguration
        let paragraphStyle = NSMutableParagraphStyle()
        let indentation = CGFloat(listContext.indentationLevel) * renderingConfig.textList.indentationMultiplier

        // The first tab stop defines the x-position where the bullet or index is drawn.
        // The second tab stop defines the x-position where the list content begins.
        let tabStops = [
            NSTextTab(textAlignment: .left, location: indentation, options: [:]),
            NSTextTab(textAlignment: .left, location: indentation + renderingConfig.textList.distanceToListItem, options: [:])
        ]

        paragraphStyle.tabStops = tabStops

        // Indent subsequent lines to line up with first tab stop after bullet.
        paragraphStyle.headIndent = indentation + renderingConfig.textList.distanceToListItem

        paragraphStyle.paragraphSpacing = renderingConfig.textConfiguration.paragraphSpacing
        paragraphStyle.lineSpacing = renderingConfig.textConfiguration.lineSpacing

        addAttributes([.paragraphStyle: paragraphStyle], range: fullRange)
    }
}
