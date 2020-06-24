// RichTextRenderer

import Contentful

/**
 A renderer for a `Contentful.UnorderedList` node. This renderer will mutate the passed-in context and pass in that
 mutated context to its child nodes to ensure that the correct list item indicator (i.e. a bullet, or ordered list
 index character) is prepended to the content and it will also ensure the proper indentation is applied
 to the contained content.
 */
open class UnorderedListRenderer: NodeRendering {
    public typealias NodeType = UnorderedList

    public func render(
        node: UnorderedList,
        rootRenderer: RichTextDocumentRendering,
        context: [CodingUserInfoKey : Any]
    ) -> [NSMutableAttributedString] {
        var mutableContext = context
        var listContext = mutableContext[.listContext] as! ListContext
        if let parentType = listContext.parentType, parentType == .unorderedList {
            listContext.incrementIndentLevel(incrementNestingLevel: true)
        } else {
            listContext.incrementIndentLevel(incrementNestingLevel: false)
        }
        listContext.parentType = .unorderedList
        mutableContext[.listContext] = listContext

        let contentNodes = node.content.compactMap { $0 as? RenderableNodeProviding }
        let result = contentNodes.reduce(into: [NSMutableAttributedString()]) { result, contentNode in
            let renderedNode = rootRenderer.render(
                node: contentNode,
                context: context
            )

            result.append(contentsOf: renderedNode)
        }

        return result
    }
}
