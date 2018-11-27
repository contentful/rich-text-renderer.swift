//
//  HorizontalRuleRenderer.swift
//  ContentfulRichTextRenderer
//
//  Created by JP Wright on 01/11/18.
//  Copyright © 2018 Contentful GmbH. All rights reserved.
//

import Foundation
import UIKit
import Contentful

/// Conform to this protocol to create custom views for `Contentful.HorizontalRule` nodes that are part of
/// a `Contentful.RichTextDocument`.
public protocol HorizontalRuleProvider {
    /// This function should return the view which will be rendered for a `Contentful.HorizontalRule` node.
    func horizontalRule(context: [CodingUserInfoKey: Any]) -> View
}

/// The default `HorizontalRuleProvider` provided by this library and used by the default `RenderingConfiguration` instance.
public struct DefaultHorizontalRuleProvider: HorizontalRuleProvider {
    public func horizontalRule(context: [CodingUserInfoKey: Any]) -> View {
        let view = View(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height:  1.0))
        view.backgroundColor = .lightGray
        return view
    }
}

/// A renderer for a `Contentful.HorizontalRule` node. This renderer will use the `HorizontalRuleProvider`
/// attached to the `RenderingConfiguration` which is available via the `context` Dictionary to attach
/// a `NSAttributedString.Key`, `UIView` pair to the range of characters that comprise the node.
public struct HorizontalRuleRenderer: NodeRenderer {

    public func render(node: Node, renderer: RichTextRenderer, context: [CodingUserInfoKey : Any]) -> [NSMutableAttributedString] {
        let provider = context.styleConfig.horizontalRuleProvider

        let semaphore = DispatchSemaphore(value: 0)
        var hrView: View!

        // Dispatching synchronously to the main thread when you're on the main thread crashes. This generally happens in testing scenarios.
        let callback: () -> Void = {
            hrView = provider.horizontalRule(context: context)
            semaphore.signal()
        }
        if Thread.isMainThread {
            callback()
        } else {
            DispatchQueue.main.sync {
                callback()
            }
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)

        var rendered = [NSMutableAttributedString(string: "\0", attributes: [.horizontalRule: hrView])]
        rendered.applyListItemStylingIfNecessary(node: node, context: context)
        rendered.appendNewlineIfNecessary(node: node)
        return rendered
    }
}
