// RichTextRenderer

import Contentful

/**
 A renderer for a `Contentful.ListItem` node. This renderer will mutate the passed-in context and pass that mutated
 context to its child nodes to ensure that the correct list item indicator (i.e. a bullet, or ordered
 list index character) is prepended to the content and it will also ensure the proper indentation is applied
 to the contained content.
 */
open class ListItemRenderer: NodeRendering {
    public typealias NodeType = ListItem

    required public init() {}

    open func render(
        node: ListItem,
        rootRenderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey : Any]
    ) -> [NSMutableAttributedString] {
        var mutableContext = context
        var listContext = mutableContext[.listContext] as! ListContext
        listContext.isFirstListItemChild = true
        mutableContext[.listContext] = listContext

        let contentNodes = node.content.compactMap { $0 as? RenderableNodeProviding }
        let result = contentNodes.reduce(into: [NSMutableAttributedString]()) { result, contentNode in
            let renderedNode = rootRenderer.render(
                node: contentNode,
                context: mutableContext
            )

            listContext.isFirstListItemChild = false
            mutableContext[.listContext] = listContext

            result.append(contentsOf: renderedNode)
        }

        return result
    }
}
