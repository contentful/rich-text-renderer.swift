// RichTextRenderer

import UIKit

/// A custom `NSLayoutManager` subclass which has special handling for rendering `Contentful.BlockQuote` nodes
/// with custom drawing.
public class RichTextLayoutManager: NSLayoutManager {

    var blockQuoteWidth: CGFloat!

    var blockQuoteColor: UIColor!

    var textContainerInset: UIEdgeInsets!

    public override init() {
        super.init()
        allowsNonContiguousLayout = true
    }

    public override var hasNonContiguousLayout: Bool {
        return true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // This draws the quote decoration block...need to make sure it works for both LtR and RtL languages.
    public override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        super.drawBackground(forGlyphRange: glyphsToShow, at: origin)

        // Draw the quote.
        let characterRange = self.characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
        textStorage?.enumerateAttributes(in: characterRange, options: []) { (attrs, range, _) in
            guard attrs[.block] != nil else { return }
            let context = UIGraphicsGetCurrentContext()
            context?.setLineWidth(0)

            self.blockQuoteColor.setFill()
            context?.saveGState()

            let textContainer = textContainers.first!
            let theseGlyphys = self.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
            var frame = boundingRect(forGlyphRange: theseGlyphys, in: textContainer)

            frame.size.width = blockQuoteWidth
            frame.origin.x = textContainerInset.left + textContainers.first!.lineFragmentPadding
            frame.origin.y += textContainers.first!.lineFragmentPadding
            frame.size.height += textContainers.first!.lineFragmentPadding * 2
            context?.saveGState()
            context?.fill(frame)
            context?.stroke(frame)
            context?.restoreGState()
        }
    }
}
