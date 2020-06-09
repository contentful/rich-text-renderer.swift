//
//  DefaultRichTextRenderer.swift
//  ContentfulRichTextRenderer
//
//  Created by JP Wright on 9/25/18.
//  Copyright © 2018 Contentful GmbH. All rights reserved.
//

import Foundation
import Contentful

/// The default `RichTextRenderer` provided by this library. All instance variables/properties on this
/// type have sane defaults which will render the relevant nodes accordingly. If you wish to customize any particular
/// renderer, simply create your own type conforming to `NodeRenderer` and assign it to the instance variable
/// on the `DefaultRichTextRenderer`.
public struct DefaultRichTextRenderer: RichTextRenderer {

    public var config: RendererConfiguration = RendererConfiguration()

    /// The renderer for `Contentful.Heading` nodes. Defaults to an instance of `HeadingRenderer`.
    public var headingRenderer: NodeRenderer = HeadingRenderer()

    /// The renderer for `Contentful.Text` nodes. Defaults to an instance of `TextRenderer`.
    public var textRenderer: NodeRenderer = TextRenderer()

    /// The renderer for `Contentful.OrderedList` nodes. Defaults to an instance of `OrderedListRenderer`.
    public var orderedListRenderer: NodeRenderer = OrderedListRenderer()

    /// The renderer for `Contentful.UnorderedList` nodes. Defaults to an instance of `UnorderedListRenderer`.
    public var unorderedListRenderer: NodeRenderer = UnorderedListRenderer()

    /// The renderer for `Contentful.BlockQuote` nodes. Defaults to an instance of `BlockQuoteRenderer`.
    public var blockQuoteRenderer: NodeRenderer = BlockQuoteRenderer()

    /// The renderer for `Contentful.ListItem` nodes. Defaults to an instance of `ListItemRenderer`.
    public var listItemRenderer: NodeRenderer = ListItemRenderer()

    /// The renderer for node types that are not yet supported by this library. Defaults to an instance of `EmptyRenderer`.
    public var emptyRenderer: NodeRenderer = EmptyRenderer()

    /// The renderer for `Contentful.Paragraph` nodes. Defaults to an instance of `ParagraphRenderer`.
    public var paragraphRenderer: NodeRenderer = ParagraphRenderer()

    /// The renderer for `Contentful.Hyperlink` nodes. Defaults to an instance of `HeadingRenderer`.
    public var hyperlinkRenderer: NodeRenderer = HyperlinkRenderer()

    /// The renderer for `Contentful.ResourceLinkBlock` nodes. Defaults to an instance of `ResourceLinkBlockRenderer`.
    public var resourceLinkBlockRenderer: NodeRenderer = ResourceLinkBlockRenderer()

    /// The renderer for `Contentful.ResourceLinkInline` nodes. Defaults to an instance of `ResourceLinkInlineRenderer`.
    public var resourceLinkInlineRenderer: NodeRenderer = ResourceLinkInlineRenderer()

    /// The renderer for `Contentful.HorizontalRule` nodes. Defaults to an instance of `HorizontalRuleRenderer`.
    public var horizontalRuleRenderer: NodeRenderer = HorizontalRuleRenderer()

    public init(styleConfig: RendererConfiguration) {
        self.config = styleConfig
    }

    /// Initializes an instance of `DefaultRichTextRenderer` with default renderers and default styling configuration.
    public init() {}

    /// The starting context with which to render the `RichTextDocument`.
    public var baseContext: [CodingUserInfoKey: Any] {
        return [
            .rendererConfiguration: config,
            .listContext: ListContext(level: 0,
                                      indentationLevel: 0,
                                      parentType: nil,
                                      itemIndex: 0,
                                      isFirstListItemChild: false)
        ]
    }

    public func render(document: RichTextDocument) -> NSAttributedString {
        let context = baseContext
        let renderedChildren = document.content.reduce(into: [NSMutableAttributedString]()) { (rendered, node) in
            let nodeRenderer = self.renderer(for: node)
            let renderedNodes = nodeRenderer.render(node: node, renderer: self, context: context)
            rendered.append(contentsOf: renderedNodes)
        }
        let string = renderedChildren.reduce(into: NSMutableAttributedString()) { (rendered, next) in
            rendered.append(next)
        }
        return string
    }

    public func renderer(for node: Node) -> NodeRenderer {
        switch node.nodeType {
        case .h1, .h2, .h3, .h4, .h5, .h6:
            return headingRenderer

        case .text:
            return textRenderer

        case .paragraph:
            return paragraphRenderer

        case .orderedList:
            return orderedListRenderer

        case .unorderedList:
            return unorderedListRenderer

        case .listItem:
            return listItemRenderer

        case .blockquote:
            return blockQuoteRenderer

        case .hyperlink:
            return hyperlinkRenderer

        case .document:
            return emptyRenderer

        case .embeddedEntryBlock, .embeddedAssetBlock:
            return resourceLinkBlockRenderer

        case .horizontalRule:
            return horizontalRuleRenderer

        case .embeddedEntryInline, .assetHyperlink, .entryHyperlink:
            return resourceLinkInlineRenderer
        }
    }


    /// Returns the font for a text node that has the correct attributes: i.e. bold, italicized, etc.
    ///
    /// - Parameters:
    ///   - textNode: The text node which has `marks` desribing the required font.
    ///   - styleConfiguration: The styling configuration which holds the base font to render with.
    /// - Returns: An instance of `UIFont` on iOS and tvOS, or an instance of `NSFont` on macOS.
    public static func font(for textNode: Text, config: RendererConfiguration) -> Font {
        let markTypes = textNode.marks.map { $0.type }

        var font: Font?

        if markTypes.contains(.bold) && markTypes.contains(.italic) {
            font = config.baseFont.italicizedAndBolded()
        } else if markTypes.contains(.bold) {
            font = config.baseFont.bolded()
        } else if markTypes.contains(.italic) {
            font = config.baseFont.italicized()
        } else if markTypes.contains(.code) {
            font = config.baseFont.monospaced()
        }
        if let font = font {
            return font
        } else {
            // TODO: Log that no font was found for the relevant traits.
            return config.baseFont
        }
    }
}
