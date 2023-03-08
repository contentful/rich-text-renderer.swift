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
    
    func view(
        node: NodeType,
        rootRenderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey: Any]
    ) -> UIView?
}

extension NodeRendering {
    public func view(
        node: NodeType,
        rootRenderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey: Any]
    ) -> UIView? {
        return nil
    }
}
