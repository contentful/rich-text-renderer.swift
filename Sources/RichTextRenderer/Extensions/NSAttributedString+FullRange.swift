// RichTextRenderer

import Foundation

extension NSAttributedString {
    /// Returns range representing entire string.
    var fullRange: NSRange {
        NSRange(location: 0, length: length)
    }
}
