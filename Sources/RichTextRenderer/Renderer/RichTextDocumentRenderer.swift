// RichTextRenderer

import Contentful
import UIKit

/// Renderer for `Contentful.RichTextDocument`.
public struct RichTextDocumentRenderer: RichTextDocumentRendering {

    /// Configuration of the renderer.
    public let configuration: RendererConfiguration
    
    private let nodeRenderers: NodeRenderersProviding

    public init(
        configuration: RendererConfiguration = DefaultRendererConfiguration(),
        nodeRenderers: NodeRenderersProviding = DefaultRenderersProvider()
    ) {
        self.configuration = configuration
        self.nodeRenderers = nodeRenderers
    }

    public func render(document: RichTextDocument) -> NSAttributedString {
        let context = makeRenderingContext()

        let contentNodes = document.content.compactMap { $0 as? RenderableNodeProviding }
        let results = contentNodes.reduce(into: [NSMutableAttributedString]()) { result, contentNode in
            let renderedNode = render(
                node: contentNode,
                context: context
            )

            result.append(contentsOf: renderedNode)
        }
        var i = 0
        let result = results.reduce(into: NSMutableAttributedString()) { result, child in
            
            // Remove the very bottom empty line space under the document as it is unnecessary
            if i < results.count - 1 {
                result.append(child)
            }
            i += 1
        }

        return result
    }

    public func render(
        node: RenderableNodeProviding,
        context: [CodingUserInfoKey: Any]
    ) -> [NSMutableAttributedString] {
        return nodeRenderers.render(
            node: node.renderableNode,
            renderer: self,
            context: context
        )
    }

    private func makeRenderingContext() -> [CodingUserInfoKey: Any] {
        [.rendererConfiguration: configuration]
    }
}
