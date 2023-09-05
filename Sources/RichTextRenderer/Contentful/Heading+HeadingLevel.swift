// RichTextRenderer

import Contentful
import Foundation

extension Heading {
    var headingLevel: HeadingLevel {
        let theLevel: Int = Int(level ?? 1)
        return HeadingLevel(rawValue: theLevel) ?? HeadingLevel.h1
    }
}
