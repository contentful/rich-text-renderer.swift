// RichTextRenderer

import UIKit

/// Configuration for rendering `BlockQuote` node.
public struct BlockQuoteConfiguration {

    /// Color of the rectangle presented next to the quote.
    public let rectangleColor: UIColor

    /// Width of the rectangle presented next to the quote.
    public let rectangleWidth: CGFloat

    /// Distance of the text from the rectangle.
    public let textInset: CGFloat

    public init(
        rectangleColor: UIColor,
        rectangleWidth: CGFloat,
        textInset: CGFloat
    ) {
        self.rectangleColor = rectangleColor
        self.rectangleWidth = rectangleWidth
        self.textInset = textInset
    }
}
