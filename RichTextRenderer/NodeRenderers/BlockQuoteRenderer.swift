//
//  BlockQuoteRenderer.swift
//  ContentfulRichTextRenderer
//
//  Created by JP Wright on 9/26/18.
//  Copyright © 2018 Contentful GmbH. All rights reserved.
//

import Foundation
import Contentful

/// A renderer for a `Contentful.BlockQuote` node. This renderer applies a custom `NSAttributedString.Key` and value pair
/// to the range of characters that comprise the node. The `RichTextViewController` and its `RichTextLayoutManager` and `RichTextContainer` will recognize this attribute and layout the text with horizontal bar on the leading edge of the text block.
public struct BlockQuoteRenderer: NodeRenderer {

    public func render(node: Node, renderer: RichTextRenderer, context: [CodingUserInfoKey: Any]) -> [NSMutableAttributedString] {
        let blockQuote = node as! BlockQuote

        let renderedChildren = blockQuote.content.reduce(into: [NSMutableAttributedString]()) { (rendered, node) in
            let nodeRenderer = renderer.renderer(for: node)
            let renderedChildren = nodeRenderer.render(node: node, renderer: renderer, context: context)
            rendered.append(contentsOf: renderedChildren)
        }

        let quoteString = renderedChildren.reduce(into: NSMutableAttributedString()) { (mutableString, renderedChild) in
            mutableString.append(renderedChild)
        }
        let attrs: [NSAttributedString.Key: Any] = [.block: true]

        quoteString.addAttributes(attrs, range: NSRange(location: 0, length: quoteString.length))
        var rendered = [quoteString]
        rendered.applyListItemStylingIfNecessary(node: node, context: context)
        rendered.appendNewlineIfNecessary(node: node)
        return rendered
    }
}
