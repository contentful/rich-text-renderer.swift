// RichTextRenderer

import Contentful

/// Conform to this protocol to render `RichTextDocument`.
public protocol RichTextRendering {

    /// Renders entire `RichTextDocument` as `NSAttributedString`.
    func render(document: RichTextDocument) -> NSAttributedString

    /// Renderer configuration.
    var configuration: RendererConfiguration { get set }

    /// Renderers for different types of nodes.
    var nodeRenderers: NodeRenderersProviding { get set }
}
