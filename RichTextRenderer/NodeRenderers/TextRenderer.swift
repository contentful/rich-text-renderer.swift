//
//  TextRenderer.swift
//  ContentfulRichTextRenderer
//
//  Created by JP Wright on 9/26/18.
//  Copyright © 2018 Contentful GmbH. All rights reserved.
//

import Foundation
import Contentful

/// A renderer for a `Contentful.Text` node. This renderer will introspect the `Text` node's marks to apply
/// the proper fonts to the range of characters that comprise the node.
/// Font types and sizes are provided in the `RendererConfiguration` passed into the `DefaultRichTextRenderer`.
public struct TextRenderer: NodeRenderer {

    public func render(node: Node, renderer: RichTextRenderer, context: [CodingUserInfoKey: Any]) -> [NSMutableAttributedString] {
        let text = node as! Text
        let renderingConfig = context.styleConfiguration

        let paragraphStyle = MutableParagraphStyle()
        paragraphStyle.lineSpacing = renderingConfig.textConfiguration.lineSpacing
        paragraphStyle.paragraphSpacing = renderingConfig.textConfiguration.paragraphSpacing

        let attributes: [NSAttributedString.Key: Any] = [
            .font: renderingConfig.fontProvider.font(for: text),
            .paragraphStyle: paragraphStyle
        ]
        let attributedString = NSMutableAttributedString(string: text.value, attributes: attributes)
        return [attributedString]
    }
}
