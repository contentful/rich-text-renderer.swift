//
//  HorizontalRuleRenderer.swift
//  ContentfulRichTextRenderer
//
//  Created by JP Wright on 01/11/18.
//  Copyright © 2018 Contentful GmbH. All rights reserved.
//

import Foundation
import Contentful

/// A renderer for a `Contentful.HorizontalRule` node. This renderer will use the `HorizontalRuleProvider`
/// attached to the `RenderingConfiguration` which is available via the `context` Dictionary to attach
/// a `NSAttributedString.Key`, `UIView` pair to the range of characters that comprise the node.
public struct HorizontalRuleRenderer: NodeRenderer {
    
    public func render(node: Node, renderer: RichTextRenderer, context: [CodingUserInfoKey : Any]) -> [NSMutableAttributedString] {
        let provider = context.rendererConfiguration.horizontalRuleViewProvider

        let semaphore = DispatchSemaphore(value: 0)
        var hrView: View!

        DispatchQueue.main.sync {
            hrView = provider.horizontalRule(context: context)
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)

        var rendered = [NSMutableAttributedString(string: "\0", attributes: [.horizontalRule: hrView])]
        rendered.applyListItemStylingIfNecessary(node: node, context: context)
        rendered.appendNewlineIfNecessary(node: node)
        return rendered
    }
}
