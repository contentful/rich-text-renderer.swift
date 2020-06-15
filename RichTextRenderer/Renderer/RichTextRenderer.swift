// RichTextRenderer

import Contentful

/// Conform to this protocol to render `RichTextDocument`.
public protocol RichTextRenderer {

    /// Return correct renderer for passed in `Node`.
    func renderer(for node: Node) -> NodeRenderer

    /// Renders entire `RichTextDocument` as `NSAttributedString`.
    func render(document: RichTextDocument) -> NSAttributedString

    /// Renderer configuration.
    var configuration: RendererConfiguration { get set }
}
