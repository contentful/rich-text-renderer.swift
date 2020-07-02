// RichTextRenderer

import UIKit

/// Font definitions for headings.
public struct HeadingFonts {
    let h1: UIFont
    let h2: UIFont
    let h3: UIFont
    let h4: UIFont
    let h5: UIFont
    let h6: UIFont

    public init(
        h1: UIFont,
        h2: UIFont,
        h3: UIFont,
        h4: UIFont,
        h5: UIFont,
        h6: UIFont
    ) {
        self.h1 = h1
        self.h2 = h2
        self.h3 = h3
        self.h4 = h4
        self.h5 = h5
        self.h6 = h6
    }

    func font(for level: HeadingLevel) -> UIFont {
        switch level {
        case .h1:
            return h1

        case .h2:
            return h2

        case .h3:
            return h3

        case .h4:
            return h4

        case .h5:
            return h5

        case .h6:
            return h6
        }
    }
}
