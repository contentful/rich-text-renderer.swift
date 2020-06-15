//
//  ParagraphRenderer.swift
//  ContentfulRichTextRenderer
//
//  Created by JP Wright on 9/26/18.
//  Copyright © 2018 Contentful GmbH. All rights reserved.
//

import Foundation
import Contentful

/// A renderer for a `Contentful.Paragraph` node. Generally, this renderer doesn't have any special considerations
/// as it simply renders its child content nodes by delegating to their renderers.
public struct ParagraphRenderer: NodeRenderer {

    public func render(node: Node, renderer: RichTextRenderer, context: [CodingUserInfoKey: Any]) -> [NSMutableAttributedString] {
        let paragraph = node as! Paragraph
        var rendered = paragraph.content.reduce(into: [NSMutableAttributedString]()) { (rendered, node) in
            if let nodeRenderer = renderer.nodeRenderers.renderer(for: node) {
                let renderedChildren = nodeRenderer.render(node: node, renderer: renderer, context: context)
                rendered.append(contentsOf: renderedChildren)
            }
        }
        rendered.applyListItemStylingIfNecessary(node: node, context: context)
        rendered.appendNewlineIfNecessary(node: node)
        return rendered
    }
}
