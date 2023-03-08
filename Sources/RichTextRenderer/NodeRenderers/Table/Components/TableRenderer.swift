import Contentful
import UIKit

/// A renderer for `Contentful.Table` node.
open class TableRenderer: NodeRendering {
    public typealias NodeType = Table

    required public init() {}

    open func render(
        node: Table,
        rootRenderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey : Any]
    ) -> [NSMutableAttributedString] {
        guard let view = view(
            node: node,
            rootRenderer: rootRenderer,
            context: context
        ) else {
            return []
        }

        var rendered = [NSMutableAttributedString(string: "\0", attributes: [.embed: view])] // use null character
        rendered.applyListItemStylingIfNecessary(node: node, context: context)
        rendered.append(.makeNewLineString())
        
        return rendered
    }
    
    public func view(
        node: Table,
        rootRenderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey : Any]) -> UIView? {
        let contentNodes = node.content.compactMap { $0 as? RenderableNodeProviding }
        let result = contentNodes.reduce(into: [UIView]()) { result, contentNode in
            var subview: UIView? = nil
            if let cn = contentNode as? TableRow {
                subview = rootRenderer.nodeRenderers.tableRow.view(
                    node: cn,
                    rootRenderer: rootRenderer,
                    context: context
                )
            }

            if let v = subview {
                result.append(v)
            }
        }
        return SimpleTableView(rows: result)
    }
}
