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

/// Conform to this protocol to create custom string for `Contentful.ResourceLinkInlinee` nodes that are part of
/// a `Contentful.RichTextDocument`.
public protocol InlineProvider {
    func string(for resource: FlatResource, context: [CodingUserInfoKey: Any]) -> NSMutableAttributedString
}

/// A custom `InlineProvider` which will return an empty string.
public struct EmptyInlineProvider: InlineProvider {

    public func string(for resource: FlatResource, context: [CodingUserInfoKey: Any]) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: "")
    }
}

/// A renderer for a `Contentful.ResourceLinkBlock` node. This renderer will use the `InlineProvider`
/// attached to the `RenderingConfiguration` which is available via the `context` Dictionary to grab the string
/// which should be used to render this node.
public struct ResourceLinkInlineRenderer: NodeRenderer {

    public func render(node: Node, renderer: RichTextRenderer, context: [CodingUserInfoKey: Any]) -> [NSMutableAttributedString] {
        let embeddedResourceNode = node as! ResourceLinkInline
        guard let resolvedResource = embeddedResourceNode.data.resolvedResource else { return [] }

        let provider = context.styleConfig.inlineResourceProvider

        var rendered = [provider.string(for: resolvedResource, context: context)]

        rendered.applyListItemStylingIfNecessary(node: node, context: context)
        rendered.appendNewlineIfNecessary(node: node)
        return rendered
    }
}
