// RichTextRenderer

import UIKit

final class BlockLineFragmentProvider: LineFragmentProviding {
    private let blockQuoteConfiguration: BlockQuoteConfiguration

    init(blockQuoteConfiguration: BlockQuoteConfiguration) {
        self.blockQuoteConfiguration = blockQuoteConfiguration
    }

    func lineFragmentRect(
        forProposedRect proposedRect: CGRect,
        at characterIndex: Int,
        writingDirection baseWritingDirection: NSWritingDirection,
        remaining remainingRect: UnsafeMutablePointer<CGRect>?,
        textStorage: NSTextStorage
    ) -> CGRect? {
        guard characterIndex < textStorage.length else { return nil }

        if textStorage.attribute(.block, at: characterIndex, effectiveRange: nil) != nil {
            return proposedRect.insetBy(dx: blockQuoteConfiguration.textInset, dy: 0.0)
        }

        return nil
    }
}
