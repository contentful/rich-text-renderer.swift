// RichTextRenderer

import Contentful
import UIKit

extension Swift.Array where Element == NSMutableAttributedString {
    mutating func appendNewlineIfNecessary(node: Node) {
        guard node is BlockNode else { return }
        append(NSMutableAttributedString(string: "\n"))
    }

    mutating func applyListItemStylingIfNecessary(node: Node, context: [CodingUserInfoKey: Any]) {

        // check the current node and if it has children,
        // if any of children are blocks, mutate and pass down context.
        // if it doesn’t have children, apply styles, clear conte
        guard node is Text || (node as? BlockNode)?.content.filter({ $0 is BlockNode }).count == 0 else {
            return
        }

        guard let listContext = context[.listContext] as? ListContext else { return }

        // Get the character for the index.
        let listIndex = listContext.itemIndex
        let listChar = listContext.listChar(at: listIndex) ?? ""

        if listContext.isFirstListItemChild {
            let attributedString = NSMutableAttributedString(string: "\t" + listChar + "\t")

            attributedString.addAttributes(
                [.foregroundColor: UIColor.rtrLabel],
                range: attributedString.fullRange
            )

            if let heading = node as? Heading {
                let configuration = context[.rendererConfiguration] as! RendererConfiguration

                let attributes: [NSAttributedString.Key: Any] = [
                    .font: configuration.heading.fonts.font(for: heading.headingLevel)
                ]

                attributedString.addAttributes(
                    attributes,
                    range: attributedString.fullRange
                )
            }

            insert(attributedString, at: 0)

        } else if node is BlockNode {
            for _ in 0...listContext.indentationLevel {
                insert(NSMutableAttributedString(string: "\t"), at: 0)
            }
        }

        forEach { string in
            string.applyListItemStyling(node: node, context: context)
        }
    }
}

