// RichTextRenderer

import UIKit

/// The custom `NSTextContainer` which has handling for rendering `Contentful.BlockQuote` nodes
/// with a custom area.
public class RichTextContainer: NSTextContainer {
    private let blockQuoteConfiguration: BlockQuoteConfiguration

    init(
        size: CGSize,
        blockQuoteConfiguration: BlockQuoteConfiguration
    ) {
        self.blockQuoteConfiguration = blockQuoteConfiguration
        super.init(size: size)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func lineFragmentRect(
        forProposedRect proposedRect: CGRect,
        at characterIndex: Int,
        writingDirection baseWritingDirection: NSWritingDirection,
        remaining remainingRect: UnsafeMutablePointer<CGRect>?
    ) -> CGRect {
        let output = super.lineFragmentRect(
            forProposedRect: proposedRect,
            at: characterIndex,
            writingDirection: baseWritingDirection,
            remaining: remainingRect
        )

        guard let textStorage = layoutManager?.textStorage,
            characterIndex < textStorage.length
        else {
            return output
        }

        if textStorage.attribute(.block, at: characterIndex, effectiveRange: nil) != nil {
            return output.insetBy(dx: blockQuoteConfiguration.textInset, dy: 0.0)
        } else {
            return output
        }
    }
}
