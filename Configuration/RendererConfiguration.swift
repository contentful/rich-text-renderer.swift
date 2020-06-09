// ContentfulRichTextRenderer

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


/// A `RenderingConfiguration` describes all the configuration that should be used to render a `RichTextDocument`
/// with a `RichTextRenderer`.
public struct RendererConfiguration {

    public init() {}

    /// An instance of `RenderingConfiguration` with all variables set to defaults.
    public static let `default` = RendererConfiguration()

    /// The base font with which to begin styling. Defaults to the standard system font size.
    public var baseFont = Font.systemFont(ofSize: Font.systemFontSize)

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
