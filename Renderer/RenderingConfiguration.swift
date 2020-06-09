//
//  RichTextRendering.swift
//  ContentfulRichTextRenderer
//
//  Created by JP Wright on 29.08.18.
//  Copyright © 2018 Contentful GmbH. All rights reserved.
//

import Foundation
import CoreGraphics
import Contentful


#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(macOS)
import Cocoa
import AppKit
#endif

#if os(iOS) || os(tvOS) || os(watchOS)
/// If building for iOS, tvOS, or watchOS, `View` aliases to `UIView`. If building for macOS
/// `View` aliases to `NSView`
public typealias Color = UIColor
public typealias Font = UIFont
public typealias FontDescriptor = UIFontDescriptor
public typealias View = UIView
#else
/// If building for iOS, tvOS, or watchOS, `View` aliases to `UIView`. If building for macOS
/// `View` aliases to `NSView`
public typealias Color = NSColor
public typealias Font = NSFont
public typealias FontDescriptor = NSFontDescriptor
public typealias View = NSView
#endif

public extension NSAttributedString.Key {
    public static let block = NSAttributedString.Key(rawValue: "ContentfulBlockAttribute")
    public static let embed = NSAttributedString.Key(rawValue: "ContentfulEmbed")
    public static let horizontalRule = NSAttributedString.Key(rawValue: "ContentfulHorizontalRule")
}


/// A `RenderingConfiguration` describes all the configuration that should be used to render a `RichTextDocument`
/// with a `RichTextRenderer`.
public struct RenderingConfiguration {

    public init() {}

    /// An instance of `RenderingConfiguration` with all variables set to defaults.
    public static let `default` = RenderingConfiguration()

    /// The base font with which to begin styling. Defaults to the standard system font size.
    public var baseFont = Font.systemFont(ofSize: Font.systemFontSize)

    /// The color of the text. Defaults to `UIColor.black`.
    public var textColor = Color.black

    /// The margin from the leading edge with which embeddedd views for `ResourceLinkBlock` nodes should be inset.
    /// Defaults to 10.0 points.
    public var embedMargin: CGFloat = 10.0

    /// Configuration for `Text` nodes.
    public var textConfiguration: TextConfiguration = .default

    /// Configuration for `BlockQuote` nodes.
    public var blockQuote: BlockQuoteConfiguration = .default

    /// Configuration for `Heading` nodes.
    public var heading: HeadingConfiguration = .default

    /// Configuration for text lists.
    public var textList: TextListConfiguration = .default

    /// Provides a view for `HorizontalRule` node.
    public var horizontalRuleViewProvider: HorizontalRuleViewProviding = HorizontalRuleViewProvider()

    /// Provides a string for `ResourceLinkInline` nodes.
    public var resourceLinkInlineStringProvider: ResourceLinkInlineStringProviding
        = EmptyResourceLinkInlineStringProvider()

    /// Provides a view for `ResourceLinkBlock` nodes.
    public var resourceLinkBlockViewProvider: ResourceLinkBlockViewProviding
        = EmptyResourceLinkBlockViewProvider()
}

extension Dictionary where Key == CodingUserInfoKey {
    var styleConfig: RenderingConfiguration {
        return self[.renderingConfig] as! RenderingConfiguration
    }
}

extension Swift.Array where Element == NSMutableAttributedString {
    mutating func appendNewlineIfNecessary(node: Node) {
        guard node is BlockNode else { return }
        append(NSMutableAttributedString(string: "\n"))
    }

    mutating func applyListItemStylingIfNecessary(node: Node, context: [CodingUserInfoKey: Any]) {

        // check the current node and if it has children,
        // if any of children are blocks, mutate and pass down context.
        // if it doesn’t have children, apply styles, clear conte
        guard node is Text || (node as? BlockNode)?.content.filter({ $0 is BlockNode }).count == 0 else {
            return
        }

        let listContext = context[.listContext] as! ListContext
        guard listContext.level > 0 else { return }

        // Get the character for the index.
        let listIndex = listContext.itemIndex
        let listChar = listContext.listChar(at: listIndex) ?? ""

        if listContext.isFirstListItemChild {
            insert(NSMutableAttributedString(string: "\t" + listChar + "\t"), at: 0)
        } else if node is BlockNode {
            for _ in 0...listContext.indentationLevel {
                insert(NSMutableAttributedString(string: "\t"), at: 0)
            }
        }

        forEach { string in
            string.applyListItemStyling(node: node, context: context)
        }
    }
}

public extension CodingUserInfoKey {
    /// A custom key, used by the `context` dictionary of `NodeRenderer` methods to store `RenderingConfiguration`.
    public static let renderingConfig = CodingUserInfoKey(rawValue: "renderingConfigKey")!
    /// A custom key, used by the `context` dictionary of `NodeRenderer` methods to store `ListContext`.
    public static let listContext = CodingUserInfoKey(rawValue: "listItemContextKey")!
}
