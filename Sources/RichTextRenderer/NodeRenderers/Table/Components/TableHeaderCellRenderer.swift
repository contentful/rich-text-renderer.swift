import Contentful
import UIKit

/// A renderer for `Contentful.TableRowHeaderCell` node.
open class TableRowHeaderCellRenderer: NodeRendering {
    public typealias NodeType = TableRowHeaderCell

    required public init() {}

    open func render(
        node: TableRowHeaderCell,
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
        node: TableRowHeaderCell,
        rootRenderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey : Any]) -> UIView? {
        
        return SimpleTableViewCell(
            isHeader: true,
            nodes: node.content)
    }
}
