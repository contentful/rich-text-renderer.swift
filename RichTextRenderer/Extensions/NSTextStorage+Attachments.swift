// RichTextRenderer

import UIKit

extension NSTextStorage {
    func findAttachments(
        forAttribute attribute: NSAttributedString.Key
    ) -> [Attachment] {
        var ranges = [Attachment]()

        enumerateAttribute(attribute, in: fullRange) { value, range, _ in
            if let view = value as? UIView {
                ranges.append(.init(view: view, range: range))
            }
        }
        return ranges
    }
}
