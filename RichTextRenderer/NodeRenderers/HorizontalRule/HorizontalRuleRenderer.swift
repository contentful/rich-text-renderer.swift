// RichTextRenderer

import Contentful
import UIKit

/// Renderer for a `Contentful.HorizontalRule` node.
open class HorizontalRuleRenderer: NodeRendering {
    public typealias NodeType = HorizontalRule

    public func render(
        node: HorizontalRule,
        rootRenderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey : Any]
    ) -> [NSMutableAttributedString] {
        let provider = context.rendererConfiguration.horizontalRuleViewProvider

        let semaphore = DispatchSemaphore(value: 0)
        var hrView: UIView!

        DispatchQueue.main.sync {
            hrView = provider.horizontalRule(context: context)
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)

        var rendered = [NSMutableAttributedString(string: "\0", attributes: [.horizontalRule: hrView])]
        rendered.applyListItemStylingIfNecessary(node: node, context: context)
        rendered.appendNewlineIfNecessary(node: node)
        return rendered
    }
}
