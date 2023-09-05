// RichTextRenderer

import Contentful
import UIKit

extension StyleProviding {
    /// Return a font based on the `Text.Mark`.
    func font(for textNode: Text) -> UIFont {
        let markTypes = textNode.marks.map { $0.type }

        if markTypes.contains(.bold) && markTypes.contains(.italic) {
            return boldItalic
        } else if markTypes.contains(.bold) {
            return bold
        } else if markTypes.contains(.italic) {
            return italic
        } else if markTypes.contains(.code) {
            return monospaced
        } else {
            return regular
        }
    }
    
    /// Return a color based on the `Text.Mark`.
        func color(for textNode: Text) -> UIColor {
            let markTypes = textNode.marks.map { $0.type }

            if markTypes.contains(.bold) && markTypes.contains(.italic) {
                return boldItalicColor
            } else if markTypes.contains(.bold) {
                return boldColor
            } else if markTypes.contains(.italic) {
                return italicColor
            } else if markTypes.contains(.code) {
                return monospacedColor
            } else {
                return regularColor
            }
        }
}
