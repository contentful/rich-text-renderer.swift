// RichTextRenderer

import Contentful
import UIKit

public protocol NodeRendering {
    associatedtype NodeType: Node

    init()

    func render(
        node: NodeType,
        rootRenderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey: Any]
    ) -> [NSMutableAttributedString]
}
