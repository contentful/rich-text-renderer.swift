// RichTextRenderer

import Contentful

public protocol NodeRenderer {
    /**
    Method to render a node. This method is called by instances of `RichTextRenderer` to delegate node rendering
    to the correct renderer for a given node.
     */
    func render(
        node: Node,
        renderer: RichTextRenderer,
        context: [CodingUserInfoKey: Any]
    ) -> [NSMutableAttributedString]
}
