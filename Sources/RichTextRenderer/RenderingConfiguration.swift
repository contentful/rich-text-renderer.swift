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

    /// The `ViewProvider` to render views for `ResourceLinkBlock` nodes.  Defaults to an instance of `EmptyViewProvider`
    public var viewProvider: ViewProvider = EmptyViewProvider()

    /// The `InlineProvider` to render strings for `ResourceLinkInline` nodes. Defaults to an instance of `EmptyInlineProvider`
    public var inlineResourceProvider: InlineProvider = EmptyInlineProvider()

    /// The `HorizontalRuleProvider` to render views for `HorizontalRule` nodes. Defaults to an instance of `DefaultHorizontalRuleProvider`
    public var horizontalRuleProvider: HorizontalRuleProvider  = DefaultHorizontalRuleProvider()

    /// The color of the text. Defaults to `UIColor.black`.
    public var textColor = Color.black

    /// The space between paragraphs. Defaults to 15.0 points.
    public var paragraphSpacing: CGFloat = 15.0

    /// The space between lines. Defaults to 0.0 points.
    public var lineSpacing: CGFloat = 0.0

    /// The margin from the leading edge with which embeddedd views for `ResourceLinkBlock` nodes should be inset.
    /// Defaults to 10.0 points.
    public var embedMargin: CGFloat = 10.0

    /// The point value representing the indentation increment that each list should use. Deafults to 15.0 points.
    public var indentationMultiplier: CGFloat = 15.0

    /// The distance from the leading edge of the list item indicating character to the leading edge
    /// of the first character of the list item. Defaults to 20.0 points.
    public var distanceFromBulletMinXToCharMinX: CGFloat = 20.0

    /// The color that the block quote rectangle is filled with. Defaults to `UIColor.lightGray`
    public var blockQuoteColor: Color = .lightGray

    /// The width of the block quote rectangle on the block's leading edge. Defaults to 10.0 points.
    public var blockQuoteWidth: CGFloat = 10.0

    /// The inset between the block quote rectangle and the block quote text. Defaults to 30.0 points.
    public var blockQuoteTextInset: CGFloat = 30.0

    /// The fonts for `Heading` nodes, levels 1-6.
    public var fontsForHeadingLevels: [Font] = [
        Font.systemFont(ofSize: 24.0, weight: .semibold),
        Font.systemFont(ofSize: 18, weight: .semibold),
        Font.systemFont(ofSize: 16, weight: .semibold),
        Font.systemFont(ofSize: 15, weight: .semibold),
        Font.systemFont(ofSize: 14, weight: .semibold),
        Font.systemFont(ofSize: 13, weight: .semibold)
    ]

    public func headingAttributes(level: Int) -> [NSAttributedString.Key: Any] {
        let safeLevel = level < fontsForHeadingLevels.count ? level : 0
        return [.font: fontsForHeadingLevels[safeLevel]]
    }
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

/// A renderer that renders an empty string for any passed-in node.
public struct EmptyRenderer: NodeRenderer {
    public func render(node: Node, renderer: RichTextRenderer, context: [CodingUserInfoKey: Any]) -> [NSMutableAttributedString] {
        return [NSMutableAttributedString(string: "")]
    }
}

public extension CodingUserInfoKey {
    /// A custom key, used by the `context` dictionary of `NodeRenderer` methods to store `RenderingConfiguration`.
    public static let renderingConfig = CodingUserInfoKey(rawValue: "renderingConfigKey")!
    /// A custom key, used by the `context` dictionary of `NodeRenderer` methods to store `ListContext`.
    public static let listContext = CodingUserInfoKey(rawValue: "listItemContextKey")!
}


// Code adapted from from MarkyMark.
public extension Font {

    /// Returns a bolded version of the current font, or `nil` if not available.
    public func bolded() -> Font? {
        if let descriptor = fontDescriptor.withSymbolicTraits(.traitBold) {
            return Font(descriptor: descriptor, size: pointSize)
        }
        return nil
    }

    /// Returns a italicized version of the current font, or `nil` if not available.
    public func italicized() -> Font? {
        if let descriptor = fontDescriptor.withSymbolicTraits(.traitItalic) {
            return Font(descriptor: descriptor, size: pointSize)
        }
        return nil
    }

    /// Returns `Menlo-Regular` font, as it's one of the only 2 monospaced fonts available on iOS.
    public func monospaced() -> Font? {
        return Font(name: "Menlo-Regular", size: pointSize)
    }

    /// Returns an italicized and bolded version of the current font, or `nil` if not available.
    public func italicizedAndBolded() -> Font? {
        if let descriptor = fontDescriptor.withSymbolicTraits([.traitItalic, .traitBold]) {
            return Font(descriptor: descriptor, size: pointSize)
        }
        return nil
    }
}
