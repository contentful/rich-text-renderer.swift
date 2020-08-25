// RichTextRenderer

import UIKit

final class BlockQuoteDecorationRenderer: DecorationRendering {
    private let blockQuoteConfiguration: BlockQuoteConfiguration
    private let textContainerInsets: UIEdgeInsets

    init(blockQuoteConfiguration: BlockQuoteConfiguration, textContainerInsets: UIEdgeInsets) {
        self.blockQuoteConfiguration = blockQuoteConfiguration
        self.textContainerInsets = textContainerInsets
    }

    func draw(in context: CGContext, boundingRect: CGRect, textContainer: NSTextContainer) {
        context.setLineWidth(0)
        blockQuoteConfiguration.rectangleColor.setFill()
        context.saveGState()

        var frame = boundingRect
        frame.size.width = blockQuoteConfiguration.rectangleWidth
        frame.origin.x = textContainerInsets.left + textContainer.lineFragmentPadding
        frame.origin.y += textContainerInsets.top

        context.saveGState()
        context.fill(frame)
        context.stroke(frame)
        context.restoreGState()
    }
}
