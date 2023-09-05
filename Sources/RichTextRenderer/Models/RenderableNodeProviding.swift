// RichTextRenderer

import Foundation

/// Provides a `RenderableNode` type that can be rendered.
public protocol RenderableNodeProviding {
    var renderableNode: RenderableNode { get }
}
