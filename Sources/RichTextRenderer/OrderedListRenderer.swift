//
//  OrderedListRenderer.swift
//  ContentfulRichTextRenderer
//
//  Created by JP Wright on 9/26/18.
//  Copyright © 2018 Contentful GmbH. All rights reserved.
//

import Foundation
import Contentful

/// A renderer for a `Contentful.OrderedList` node. This renderer will mutate the passed-in context and pass in that mutated context
/// to its child nodes to ensure that the correct list item indicator (i.e. a bullet, or ordered list index character) is prepended to the content
/// and it will also ensure the proper indentation is applied to the contained content.
public struct OrderedListRenderer: NodeRenderer {
    public func render(node: Node, renderer: RichTextRenderer, context: [CodingUserInfoKey: Any]) -> [NSMutableAttributedString] {
        let orderedList = node as! OrderedList

        var mutableContext = context
        var listContext = mutableContext[.listContext] as! ListContext
        if let parentType = listContext.parentType, parentType == .orderedList {
            listContext.incrementIndentLevel(incrementNestingLevel: true)
        } else {
            listContext.incrementIndentLevel(incrementNestingLevel: false)
        }
        listContext.parentType = .orderedList
        mutableContext[.listContext] = listContext

        let rendered = orderedList.content.reduce(into: [NSMutableAttributedString]()) { (rendered, node) in

            mutableContext[.listContext] = listContext
            let nodeRenderer = renderer.renderer(for: node)
            let renderedChildren = nodeRenderer.render(node: node, renderer: renderer, context: mutableContext)

            // Append to the list of all items.
            rendered.append(contentsOf: renderedChildren)

            listContext.itemIndex += 1
        }

        return rendered
    }
}
