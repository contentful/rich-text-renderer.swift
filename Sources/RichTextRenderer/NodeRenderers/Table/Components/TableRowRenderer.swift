import Contentful
import UIKit

/// A renderer for `Contentful.Table` node.
open class TableRowRenderer: NodeRendering {
    public typealias NodeType = TableRow

    required public init() {}

    open func render(
        node: TableRow,
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
        node: TableRow,
        rootRenderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey : Any]) -> UIView? {
        let contentNodes = node.content.compactMap { $0 as? RenderableNodeProviding }
        let result = contentNodes.reduce(into: [UIView]()) { result, contentNode in
            var subview: UIView? = nil
            if let cn = contentNode as? TableRowHeaderCell {
                subview = rootRenderer.nodeRenderers.tableRowHeaderCell.view(
                    node: cn,
                    rootRenderer: rootRenderer,
                    context: context
                )
            }
            if let cn = contentNode as? TableRowCell {
                subview = rootRenderer.nodeRenderers.tableRowCell.view(
                    node: cn,
                    rootRenderer: rootRenderer,
                    context: context
                )
            }

            if let v = subview {
                result.append(v)
            }
        }
            
        if let cells = result as? [SimpleTableViewCell] {
            return SimpleTableViewRow(cells: cells)
        }
        
        print("*** WARNING ***", "Table view cells type mismatch - skipping rendering")
        return UIView()
    }
}
