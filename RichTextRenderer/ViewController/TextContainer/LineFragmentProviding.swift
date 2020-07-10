// RichTextRenderer

import UIKit

protocol LineFragmentProviding {
    func lineFragmentRect(
        forProposedRect proposedRect: CGRect,
        at characterIndex: Int,
        writingDirection baseWritingDirection: NSWritingDirection,
        remaining remainingRect: UnsafeMutablePointer<CGRect>?,
        textStorage: NSTextStorage
    ) -> CGRect?
}
