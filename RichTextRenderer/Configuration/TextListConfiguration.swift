// RichTextRenderer

import CoreGraphics

/// Configuration for rendering ordered/unordered text lists.
public struct TextListConfiguration {
    /// Indentation increment.
    public let indentationMultiplier: CGFloat

    /// Distance from leading margin of the bullet/number to the first character of the list item.
    public let distanceToListItem: CGFloat
}
