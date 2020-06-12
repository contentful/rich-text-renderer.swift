// ContentfulRichTextRenderer

/// Configuration for rendering `BlockQuote` node.
public struct BlockQuoteConfiguration {

    /// Color of the rectangle presented next to the quote.
    public let rectangleColor: Color

    /// Width of the rectangle presented next to the quote.
    public let rectangleWidth: CGFloat

    /// Distance of the text from the rectangle.
    public let textInset: CGFloat

    public init(
        rectangleColor: Color,
        rectangleWidth: CGFloat,
        textInset: CGFloat
    ) {
        self.rectangleColor = rectangleColor
        self.rectangleWidth = rectangleWidth
        self.textInset = textInset
    }
}
