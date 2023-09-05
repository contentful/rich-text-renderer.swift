// RichTextRenderer

import Contentful
import UIKit

public extension Swift.Array where Element == NSMutableAttributedString {
    mutating func applyListItemStylingIfNecessary(node: Node, context: [CodingUserInfoKey: Any]) {

        // check the current node and if it has children,
        // if any of children are blocks, mutate and pass down context.
        // if it doesn’t have children, apply styles, clear context
        guard node is Text || (node as? BlockNode)?.content.filter({ $0 is BlockNode }).count == 0 else {
            return
        }

        guard let listContext = context[.listContext] as? ListContext,
            let rendererConfiguration = context[.rendererConfiguration] as? RendererConfiguration
        else { return }

        // Get the character for the index.
        let indicator = ListItemIndicatorFactory().makeIndicator(
            forListType: listContext.listType,
            atIndex: listContext.itemIndex,
            atLevel: listContext.level
        )

        if listContext.isFirstListItemChild {
            let attributedString = NSMutableAttributedString(string: "\t" + indicator + "\t")

            attributedString.addAttributes(
                [.foregroundColor: UIColor.rtrLabel],
                range: attributedString.fullRange
            )

            if let heading = node as? Heading {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: rendererConfiguration.styleProvider.headingStyles.font(for: heading.headingLevel),
                    .foregroundColor: rendererConfiguration.styleProvider.headingStyles.color(for: heading.headingLevel)
                ]

                attributedString.addAttributes(
                    attributes,
                    range: attributedString.fullRange
                )
            }

            insert(attributedString, at: 0)

        } else if node is BlockNode {
            for _ in 0...listContext.level {
                insert(NSMutableAttributedString(string: "\t"), at: 0)
            }
        }

        forEach { string in
            applyListItemStyling(
                string: string,
                rendererConfiguration: rendererConfiguration,
                listContext: listContext
            )
        }
    }

    /// This method uses all the state passed-in via the `context` to apply the proper paragraph styling
    /// to the characters contained in the passed-in node.
    private func applyListItemStyling(
        string: NSMutableAttributedString,
        rendererConfiguration: RendererConfiguration,
        listContext: ListContext
    ) {
        let paragraphStyle = NSMutableParagraphStyle()
        let indentationInPx = CGFloat(listContext.level) * rendererConfiguration.textList.indentationMultiplier

        // The first tab stop defines the x-position where the bullet or index is drawn.
        // The second tab stop defines the x-position where the list content begins.
        let firstStop: CGFloat = indentationInPx
        let nextStop: CGFloat = indentationInPx + rendererConfiguration.textList.distanceToListItem

        paragraphStyle.tabStops = [
            NSTextTab(textAlignment: .left, location: firstStop, options: [:]),
            NSTextTab(textAlignment: .left, location: nextStop, options: [:])
        ]

        // Indent subsequent lines to line up with first tab stop after bullet.
        paragraphStyle.headIndent = indentationInPx + rendererConfiguration.textList.distanceToListItem

        paragraphStyle.paragraphSpacing = rendererConfiguration.textConfiguration.paragraphSpacing
        paragraphStyle.lineSpacing = rendererConfiguration.textConfiguration.lineSpacing

        string.addAttributes([.paragraphStyle: paragraphStyle], range: string.fullRange)
    }
}
