// RichTextRenderer

import UIKit

/// The custom `NSTextContainer` which has handling for rendering `Contentful.BlockQuote` nodes
/// with a custom area.
public class RichTextContainer: NSTextContainer {

    var blockQuoteTextInset: CGFloat!

    var blockQuoteWidth: CGFloat!

    public override func lineFragmentRect(forProposedRect proposedRect: CGRect,
                                          at characterIndex: Int,
                                          writingDirection baseWritingDirection: NSWritingDirection,
                                          remaining remainingRect: UnsafeMutablePointer<CGRect>?) -> CGRect {
        let output = super.lineFragmentRect(forProposedRect: proposedRect,
                                            at: characterIndex,
                                            writingDirection: baseWritingDirection,
                                            remaining: remainingRect)

        let length = layoutManager!.textStorage!.length
        guard characterIndex < length else { return output }

        if layoutManager?.textStorage?.attribute(.block, at: characterIndex, effectiveRange: nil) != nil {
            return output.insetBy(dx: blockQuoteTextInset, dy: 0.0)
        }
        return output
    }
}
