// RichTextRenderer

import Contentful

/**
 A renderer for a `Contentful.OrderedList` node. This renderer will mutate the passed-in context and pass in
 that mutated context to its child nodes to ensure that the correct list item indicator (i.e. a bullet, or ordered
 list index character) is prepended to the content and it will also ensure the proper indentation is applied
 to the contained content.
 */
open class OrderedListRenderer: NodeRendering {
    public typealias NodeType = OrderedList

    required public init() {}

    open func render(
        node: OrderedList,
        rootRenderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey : Any]
    ) -> [NSMutableAttributedString] {
        var listContext: ListContext! = context[.listContext] as? ListContext
        if listContext == nil {
            listContext = ListContext(listType: .ordered)
        } else {
            listContext.itemIndex = 0
            listContext.level += 1

            if listContext.listType != .ordered {
                listContext.listType = .ordered
            }
        }

        var mutableContext = context
        mutableContext[.listContext] = listContext

        let contentNodes = node.content.compactMap { $0 as? RenderableNodeProviding }
        let result = contentNodes.reduce(into: [NSMutableAttributedString]()) { result, contentNode in
            mutableContext[.listContext] = listContext

            let renderedNode = rootRenderer.render(
                node: contentNode,
                context: mutableContext
            )

            result.append(contentsOf: renderedNode)

            listContext.itemIndex += 1
        }

        return result
    }
}
