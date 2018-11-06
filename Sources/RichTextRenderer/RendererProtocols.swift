//
//  RendererProtocols.swift
//  ContentfulRichTextRenderer
//
//  Created by JP Wright on 06/11/18.
//

import Foundation
import Contentful

/// The `NodeRenderer` protocol.
public protocol NodeRenderer {
    /// Method to render a node. This method is called by instances of `RichTextRenderer` to delegate
    /// node rendering to the correct renderer for a given node.
    func render(node: Node, renderer: RichTextRenderer, context: [CodingUserInfoKey: Any]) -> [NSMutableAttributedString]
}

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
