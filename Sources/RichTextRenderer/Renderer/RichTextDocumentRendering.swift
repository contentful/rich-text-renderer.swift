// RichTextRenderer

import Contentful
import UIKit

/// Conform to this protocol to render `RichTextDocument`.
public protocol RichTextDocumentRendering {
    /// Renderer configuration.
    var configuration: RendererConfiguration { get }

    /// Renders entire `RichTextDocument` as `NSAttributedString`.
    func render(document: RichTextDocument) -> NSAttributedString

    /// Renders a `Contentful.Node`.
    func render(
        node: RenderableNodeProviding,
        context: [CodingUserInfoKey: Any]
    ) -> [NSMutableAttributedString]
}
