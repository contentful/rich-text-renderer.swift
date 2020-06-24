// RichTextRenderer

import Contentful

/**
 A renderer for a `Contentful.ResourceLinkBlock` node. This renderer will use the `ViewProvider` attached
 to the `RenderingConfiguration` which is available via the `context` Dictionary to attach a `NSAttributedString.Key`,
 `UIView` pair to the range of characters that comprise the node.
 */
open class ResourceLinkBlockRenderer: NodeRendering {
    public typealias NodeType = ResourceLinkBlock

    public func render(
        node: ResourceLinkBlock,
        rootRenderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey : Any]
    ) -> [NSMutableAttributedString] {
        guard let provider = context.rendererConfiguration.resourceLinkBlockViewProvider else { return [] }

        let semaphore = DispatchSemaphore(value: 0)

        var view: View!

        DispatchQueue.main.sync {
            view = provider.view(for: node.data.target, context: context)
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        var rendered = [NSMutableAttributedString(string: "\0", attributes: [.embed: view])] // use null character
        rendered.applyListItemStylingIfNecessary(node: node, context: context)
        rendered.appendNewlineIfNecessary(node: node)
        return rendered
    }
}
