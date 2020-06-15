//
//  ResourceLinkInlineRenderer.swift
//  ContentfulRichTextRenderer
//
//  Created by JP Wright on 31/10/18.
//  Copyright © 2018 Contentful GmbH. All rights reserved.
//

import Foundation
import Contentful

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(macOS)
import Cocoa
import AppKit
#endif

/// A renderer for a `Contentful.ResourceLinkBlock` node. This renderer will use the `InlineProvider`
/// attached to the `RenderingConfiguration` which is available via the `context` Dictionary to grab the string
/// which should be used to render this node.
public struct ResourceLinkInlineRenderer: NodeRenderer {

    public func render(node: Node, renderer: RichTextRenderer, context: [CodingUserInfoKey: Any]) -> [NSMutableAttributedString] {
        guard let embeddedResourceNode = node as? ResourceLinkInline,
            let provider = context.rendererConfiguration.resourceLinkInlineStringProvider
        else {
            return []
        }

        var rendered = [provider.string(for: embeddedResourceNode.data.target, context: context)]

        rendered.applyListItemStylingIfNecessary(node: node, context: context)
        rendered.appendNewlineIfNecessary(node: node)
        return rendered
    }
}
