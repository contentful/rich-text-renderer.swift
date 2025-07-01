// RichTextRenderer

import Contentful
import UIKit

/// Renderer for a `Contentful.Hyperlink` node.
open class HyperlinkRenderer: NodeRendering {
    public typealias NodeType = Hyperlink

    required public init() {}

    open func render(
        node: Hyperlink,
        rootRenderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey : Any]
    ) -> [NSMutableAttributedString] {
        let contentNodes = node.content.compactMap { $0 as? RenderableNodeProviding }
        let result = contentNodes.reduce(into: [NSAttributedString]()) { result, contentNode in
            let renderedNode = rootRenderer.render(
                node: contentNode,
                context: context
            )

            result.append(contentsOf: renderedNode)
        }.reduce(into: NSMutableAttributedString()) { result, child in
            result.append(child)
        }

        // Prevent crashes for links with spaces or other special characters
        let encodedURI = node.data.uri.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? node.data.uri
        
        result.addAttributes(
            [
                .link: encodedURI,
            ],
            range: result.fullRange
        )

        return [result]
    }
}
