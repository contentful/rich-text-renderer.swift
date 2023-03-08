import Contentful
import UIKit

/// A renderer for `Contentful.TableRowCell` node.
open class TableRowCellRenderer: NodeRendering {
    public typealias NodeType = TableRowCell

    required public init() {}

    open func render(
        node: TableRowCell,
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
        node: TableRowCell,
        rootRenderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey : Any]) -> UIView? {
        
        return SimpleTableViewCell(
            isHeader: false,
            nodes: node.content)
    }
}
