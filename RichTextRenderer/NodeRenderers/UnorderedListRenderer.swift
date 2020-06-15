//
//  UnorderedListRenderer.swift
//  ContentfulRichTextRenderer
//
//  Created by JP Wright on 9/26/18.
//  Copyright © 2018 Contentful GmbH. All rights reserved.
//

import Foundation
import Contentful

/// A renderer for a `Contentful.UnorderedList` node. This renderer will mutate the passed-in context and pass in that mutated context
/// to its child nodes to ensure that the correct list item indicator (i.e. a bullet, or ordered list index character) is prepended to the content
/// and it will also ensure the proper indentation is applied to the contained content.
public struct UnorderedListRenderer: NodeRenderer {
    public func render(node: Node, renderer: RichTextRenderer, context: [CodingUserInfoKey: Any]) -> [NSMutableAttributedString] {
        let unorderedList = node as! UnorderedList

        var mutableContext = context
        var listContext = mutableContext[.listContext] as! ListContext
        if let parentType = listContext.parentType, parentType == .unorderedList {
            listContext.incrementIndentLevel(incrementNestingLevel: true)
        } else {
            listContext.incrementIndentLevel(incrementNestingLevel: false)
        }
        listContext.parentType = .unorderedList
        mutableContext[.listContext] = listContext

        let rendered = unorderedList.content.reduce(into: [NSMutableAttributedString]()) { (rendered, node) in
            if let nodeRenderer = renderer.nodeRenderers.renderer(for: node) {
                let renderedChildren = nodeRenderer.render(node: node, renderer: renderer, context: mutableContext)
                rendered.append(contentsOf: renderedChildren)
            }
        }

        return rendered
    }
}
