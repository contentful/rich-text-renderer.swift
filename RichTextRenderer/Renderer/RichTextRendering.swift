// RichTextRenderer

import Contentful

/// Conform to this protocol to render `RichTextDocument`.
public protocol RichTextRendering {
    /// Renderer configuration.
    var configuration: RendererConfiguration { get }

    /// Renderers for different types of nodes.
    var nodeRenderers: NodeRenderersProviding { get }

    /// Renders entire `RichTextDocument` as `NSAttributedString`.
    func render(document: RichTextDocument) -> NSAttributedString
}
