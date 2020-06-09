// ContentfulRichTextRenderer

import Foundation
import Contentful

/// Conform to the `RichTextRenderer` protocol to render a `Contentful.RichTextDocument`.
/// A default renderer, `DefaultRichTextRenderer`, is provided by this library.
public protocol RichTextRenderer {

    /// This function should return the correct node renderer for a given node so that it may be rendered properly.
    func renderer(for node: Node) -> NodeRenderer

    /// This method should reduce the entire `Contentful.RichTextDocument` instance to a single `NSAttributedString`.
    func render(document: RichTextDocument) -> NSAttributedString

    /// The styling configuration to use when rendering the `Contentful.RichTextDocument` to an `NSAttributedString`.
    var config: RenderingConfiguration { get set }
}
