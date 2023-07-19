// RichTextRenderer

import UIKit

/// Font definitions for headings.
public struct HeadingStyles {
    let h1: UIFont
    let h1Color: UIColor
    let h2: UIFont
    let h2Color: UIColor
    let h3: UIFont
    let h3Color: UIColor
    let h4: UIFont
    let h4Color: UIColor
    let h5: UIFont
    let h5Color: UIColor
    let h6: UIFont
    let h6Color: UIColor

    public init(
        h1: UIFont, h1Color: UIColor,
        h2: UIFont, h2Color: UIColor,
        h3: UIFont, h3Color: UIColor,
        h4: UIFont, h4Color: UIColor,
        h5: UIFont, h5Color: UIColor,
        h6: UIFont, h6Color: UIColor
    ) {
        self.h1 = h1
        self.h1Color = h1Color
        self.h2 = h2
        self.h2Color = h2Color
        self.h3 = h3
        self.h3Color = h3Color
        self.h4 = h4
        self.h4Color = h4Color
        self.h5 = h5
        self.h5Color = h5Color
        self.h6 = h6
        self.h6Color = h6Color
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

    func color(for level: HeadingLevel) -> UIColor {
        switch level {
        case .h1:
            return h1Color

        case .h2:
            return h2Color

        case .h3:
            return h3Color

        case .h4:
            return h4Color

        case .h5:
            return h5Color

        case .h6:
            return h6Color
        }
    }
}

