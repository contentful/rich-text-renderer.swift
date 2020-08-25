// RichTextRenderer

import UIKit

final class Attachment {
    let view: UIView
    let range: NSRange

    init(view: UIView, range: NSRange) {
        self.view = view
        self.range = range
    }
}

