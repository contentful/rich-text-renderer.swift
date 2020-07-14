// RichTextRenderer

import Contentful
import UIKit

/// Renderer for a `Contentful.HorizontalRule` node.
open class HorizontalRuleRenderer: NodeRendering {
    public typealias NodeType = HorizontalRule

    required public init() {}

    open func render(
        node: HorizontalRule,
        rootRenderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey : Any]
    ) -> [NSMutableAttributedString] {
        let provider = context.rendererConfiguration.horizontalRuleViewProvider

        let hrView = provider.horizontalRule(context: context)
        var rendered = [NSMutableAttributedString(string: "\0", attributes: [.horizontalRule: hrView])]
        rendered.applyListItemStylingIfNecessary(node: node, context: context)
        rendered.append(.makeNewLineString())
        return rendered
    }
}
