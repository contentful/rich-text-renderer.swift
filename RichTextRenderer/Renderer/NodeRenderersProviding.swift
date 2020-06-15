// RichTextRenderer

import Contentful

public protocol NodeRenderersProviding {

    var heading: NodeRenderer { get set }
    var text: NodeRenderer { get set }
    var orderedList: NodeRenderer { get set }
    var unorderedList: NodeRenderer { get set }
    var blockQuote: NodeRenderer { get set }
    var listItem: NodeRenderer { get set }
    var paragraph: NodeRenderer { get set }
    var hyperlink: NodeRenderer { get set }
    var resourceLinkBlock: NodeRenderer { get set }
    var resourceLinkInline: NodeRenderer { get set }
    var horizontalRule: NodeRenderer { get set }
}

extension NodeRenderersProviding {
    /// Return a renderer for a node.
    public func renderer(for node: Node) -> NodeRenderer? {
        switch node.nodeType {
        case .h1, .h2, .h3, .h4, .h5, .h6:
            return heading

        case .text:
            return text

        case .paragraph:
            return paragraph

        case .orderedList:
            return orderedList

        case .unorderedList:
            return unorderedList

        case .listItem:
            return listItem

        case .blockquote:
            return blockQuote

        case .hyperlink:
            return hyperlink

        case .embeddedEntryBlock, .embeddedAssetBlock:
            return resourceLinkBlock

        case .horizontalRule:
            return horizontalRule

        case .embeddedEntryInline, .assetHyperlink, .entryHyperlink:
            return resourceLinkInline

        default:
            return nil
        }
    }
}
