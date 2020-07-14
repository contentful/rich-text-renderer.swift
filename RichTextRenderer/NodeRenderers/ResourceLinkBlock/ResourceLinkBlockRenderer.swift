// RichTextRenderer

import Contentful
import UIKit

/**
 A renderer for a `Contentful.ResourceLinkBlock` node. This renderer will use the `ViewProvider` attached
 to the `RenderingConfiguration` which is available via the `context` Dictionary to attach a `NSAttributedString.Key`,
 `UIView` pair to the range of characters that comprise the node.
 */
open class ResourceLinkBlockRenderer: NodeRendering {
    public typealias NodeType = ResourceLinkBlock

    required public init() {}

    open func render(
        node: ResourceLinkBlock,
        rootRenderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey : Any]
    ) -> [NSMutableAttributedString] {
        guard let provider = context.rendererConfiguration.resourceLinkBlockViewProvider else { return [] }

        let view = provider.view(for: node.data.target, context: context)
        var rendered = [NSMutableAttributedString(string: "\0", attributes: [.embed: view])] // use null character
        rendered.applyListItemStylingIfNecessary(node: node, context: context)
        rendered.append(.makeNewLineString())
        
        return rendered
    }
}
