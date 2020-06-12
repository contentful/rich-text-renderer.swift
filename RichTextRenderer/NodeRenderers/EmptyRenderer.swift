// RichTextRenderer

import Contentful

/// Renderer for unsupported `Node` types.
struct EmptyRenderer: NodeRenderer {
    func render(
        node: Node,
        renderer: RichTextRenderer,
        context: [CodingUserInfoKey: Any]
    ) -> [NSMutableAttributedString] {
        return [NSMutableAttributedString(string: "")]
    }
}
