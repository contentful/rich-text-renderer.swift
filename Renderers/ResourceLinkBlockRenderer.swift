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

/// A union type that bridges the current operating system's view-type with `ResourceLinkBlockRepresentable`.
public typealias ResourceBlockView = ResourceLinkBlockRepresentable & View

/// Views should conform to this protocol so that `ResourceLinkBlockRenderer` instances can apply the
/// correct `NSAttributedString.Key`, view pairs to the range of characters which comprise a `Contentful.ResourceLinkBlock` node.
public protocol ResourceLinkBlockRepresentable {

    /// This boolean determines if text should wrap along the sides of this view (if that view doesn't stretch the width of the superview),
    /// or if text should continue below.
    var surroundingTextShouldWrap: Bool { get }

    /// The passed-in context, useful ffor determining your own rendering logic.
    var context: [CodingUserInfoKey: Any] { get set }

    /// This method is called by `RichTextViewController` and is passed a width value which represents the
    /// available width within the superview. Implementing this method is useful for applying the proper height to the view based on its width.
    func layout(with width: CGFloat)
}

/// Conform to this protocol to create custom views for `Contentful.ResourceLinkBlock` nodes that are part of
/// a `Contentful.RichTextDocument`.
public protocol ViewProvider {
    /// This function should return the view which will be rendered for a `Contentful.ResourceLinkBlock` node.
    func view(for resource: FlatResource, context: [CodingUserInfoKey: Any]) -> ResourceBlockView
}

/// An empty view which can be used by custom `ViewProvider` types when encountering unsupported content types.
public class EmptyView: View, ResourceLinkBlockRepresentable {
    public var surroundingTextShouldWrap: Bool = true
    public var context: [CodingUserInfoKey: Any] = [:]
    public func layout(with width: CGFloat) {}
}

/// A custom `ViewProvider` which will return an empty view, with a `CGRect.zero` frame.
public struct EmptyViewProvider: ViewProvider {

    public func view(for resource: FlatResource, context: [CodingUserInfoKey: Any]) -> ResourceBlockView {
        return EmptyView(frame: .zero)
    }
}

/// A renderer for a `Contentful.ResourceLinkBlock` node. This renderer will use the `ViewProvider`
/// attached to the `RenderingConfiguration` which is available via the `context` Dictionary to attach
/// a `NSAttributedString.Key`, `UIView` pair to the range of characters that comprise the node.
public struct ResourceLinkBlockRenderer: NodeRenderer {

    public func render(node: Node, renderer: RichTextRenderer, context: [CodingUserInfoKey: Any]) -> [NSMutableAttributedString] {
        let embeddedResourceNode = node as! ResourceLinkBlock
        guard let resolvedResource = embeddedResourceNode.data.resolvedResource else { return [] }

        let provider = context.styleConfig.viewProvider

        let semaphore = DispatchSemaphore(value: 0)

        var view: View!

        DispatchQueue.main.sync {
            view = provider.view(for: resolvedResource, context: context)
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        var rendered = [NSMutableAttributedString(string: "\0", attributes: [.embed: view])] // use null character
        rendered.applyListItemStylingIfNecessary(node: node, context: context)
        rendered.appendNewlineIfNecessary(node: node)
        return rendered
    }
}
