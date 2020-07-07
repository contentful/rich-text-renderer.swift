// RichTextRenderer

import Contentful

/**
 A renderer for a `Contentful.ResourceLinkBlock` node. This renderer will use the `InlineProvider` attached
 to the `RenderingConfiguration` which is available via the `context` Dictionary to grab the string which
 should be used to render this node.
 */
open class ResourceLinkInlineRenderer: NodeRendering {
    public typealias NodeType = ResourceLinkInline

    public func render(
        node: ResourceLinkInline,
        rootRenderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey : Any]
    ) -> [NSMutableAttributedString] {
        guard let provider = context.rendererConfiguration.resourceLinkInlineStringProvider else { return [] }

        var rendered = [provider.string(for: node.data.target, context: context)]
        rendered.applyListItemStylingIfNecessary(node: node, context: context)

        return rendered
    }
}
