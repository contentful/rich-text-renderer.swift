// RichTextRenderer

import CoreGraphics
import Foundation

/// Configuration for rendering `Text` node.
public struct TextConfiguration {
    public let paragraphSpacing: CGFloat
    public let lineSpacing: CGFloat

    public init(
        paragraphSpacing: CGFloat,
        lineSpacing: CGFloat
    ) {
        self.paragraphSpacing = paragraphSpacing
        self.lineSpacing = lineSpacing
    }
}
