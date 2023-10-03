// RichTextRenderer

import Contentful
import UIKit

/**
 A renderer for a `Contentful.ResourceLinkBlock` node. This renderer will use the `InlineProvider` attached
 to the `RenderingConfiguration` which is available via the `context` Dictionary to grab the string which
 should be used to render this node.
 */
open class ResourceLinkInlineRenderer: NodeRendering {
    public typealias NodeType = ResourceLinkInline
    
    internal static let kContentfulLinkKey = "kContentfulLinkKey"

    required public init() {}

    open func render(
        node: ResourceLinkInline,
        rootRenderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey : Any]
    ) -> [NSMutableAttributedString] {
        
        switch node.data.target {
        case .asset(_), .entry(_), .unresolved(_):
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

            result.addAttributes(
                [
                    .link: "inlineResourceLink://\(node.data.target.id)",
                    NSAttributedString.Key(ResourceLinkInlineRenderer.kContentfulLinkKey): node.data.target
                ],
                range: result.fullRange
            )

            return [result]
        case .entryDecodable(_):
            guard let provider = context.rendererConfiguration.resourceLinkInlineStringProvider else {
                return []
            }

            var rendered = [provider.string(for: node.data.target, context: context)]
            rendered.applyListItemStylingIfNecessary(node: node, context: context)

            return rendered
        default:
            return []
        }
    }
}
