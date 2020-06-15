// RichTextRenderer

import Contentful

/// Renderer for `Contentful.RichTextDocument`.
public struct RichTextRenderer: RichTextRendering {

    public var configuration: RendererConfiguration = .default
    public var nodeRenderers: NodeRenderersProviding = DefaultRenderersProvider()

    public init() {}

    public func render(document: RichTextDocument) -> NSAttributedString {
        let context = makeRenderingContext()

        let renderedChildren = document.content.reduce(into: [NSMutableAttributedString]()) { (rendered, node) in
            if let nodeRenderer = nodeRenderers.renderer(for: node) {
                let renderedNodes = nodeRenderer.render(node: node, renderer: self, context: context)
                rendered.append(contentsOf: renderedNodes)
            }
        }

        let string = renderedChildren.reduce(into: NSMutableAttributedString()) { (rendered, next) in
            rendered.append(next)
        }

        return string
    }

    private func makeRenderingContext() -> [CodingUserInfoKey: Any] {
        [
            .rendererConfiguration: configuration,
            .listContext: ListContext(
                level: 0,
                indentationLevel: 0,
                parentType: nil,
                itemIndex: 0,
                isFirstListItemChild: false
            )
        ]
    }
}
