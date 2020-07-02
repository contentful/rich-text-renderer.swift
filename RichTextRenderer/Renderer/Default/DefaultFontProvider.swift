// RichTextRenderer

import UIKit

public struct DefaultFontProvider: FontProviding {
    private let font: UIFont

    public var regular: UIFont {
        font
    }

    public var bold: UIFont {
        if let descriptor = font.fontDescriptor.withSymbolicTraits(.traitBold) {
            return UIFont(descriptor: descriptor, size: descriptor.pointSize)
        } else {
            return font
        }
    }

    public var italic: UIFont {
        if let descriptor = font.fontDescriptor.withSymbolicTraits(.traitItalic) {
            return UIFont(descriptor: descriptor, size: descriptor.pointSize)
        } else {
            return font
        }
    }

    public var boldItalic: UIFont {
        if let descriptor = font.fontDescriptor.withSymbolicTraits([.traitItalic, .traitBold]) {
            return UIFont(descriptor: descriptor, size: descriptor.pointSize)
        } else {
            return font
        }
    }

    public var code: UIFont {
        UIFont(name: "Menlo-Regular", size: font.pointSize) ?? font
    }

    public init(font: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)) {
        self.font = font
    }
}
