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

        // Check if URL is already percent-encoded to avoid double-encoding
        // If removingPercentEncoding returns a different string, it was already encoded
        let uri: String
        if let decoded = node.data.uri.removingPercentEncoding, decoded != node.data.uri {
            // Already encoded, use as-is to avoid double-encoding (e.g., %20 becoming %2520)
            uri = node.data.uri
        } else {
            // Not encoded, encode it to handle spaces and special characters
            uri = node.data.uri.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? node.data.uri
        }
        
        result.addAttributes(
            [
                .link: uri,
            ],
            range: result.fullRange
        )

        return [result]
    }
}
