// RichTextRenderer

import Contentful

public protocol NodeRendering {
    associatedtype NodeType: Node

    func render(
        node: NodeType,
        rootRenderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey: Any]
    ) -> [NSMutableAttributedString]
}
