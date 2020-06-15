//
//  ResourceLinkBlockRenderer.swift
//  ContentfulRichTextRenderer
//
//  Created by JP Wright on 9/25/18.
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

/// A renderer for a `Contentful.ResourceLinkBlock` node. This renderer will use the `ViewProvider`
/// attached to the `RenderingConfiguration` which is available via the `context` Dictionary to attach
/// a `NSAttributedString.Key`, `UIView` pair to the range of characters that comprise the node.
public struct ResourceLinkBlockRenderer: NodeRenderer {

    public func render(node: Node, renderer: RichTextRenderer, context: [CodingUserInfoKey: Any]) -> [NSMutableAttributedString] {
        let embeddedResourceNode = node as! ResourceLinkBlock

        let provider = context.rendererConfiguration.resourceLinkBlockViewProvider

        let semaphore = DispatchSemaphore(value: 0)

        var view: View!

        DispatchQueue.main.sync {
            view = provider.view(for: embeddedResourceNode.data.target, context: context)
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        var rendered = [NSMutableAttributedString(string: "\0", attributes: [.embed: view])] // use null character
        rendered.applyListItemStylingIfNecessary(node: node, context: context)
        rendered.appendNewlineIfNecessary(node: node)
        return rendered
    }
}
