// RichTextRenderer

import UIKit

public final class DefaultFontProvider: FontProviding {
    private let baseFont: UIFont
    private let monospacedFont: UIFont

    public var regular: UIFont {
        return UIFont(descriptor: baseFont.fontDescriptor, size: baseFont.pointSize)
    }

    public var bold: UIFont {
        if let descriptor = baseFont.fontDescriptor.withSymbolicTraits(.traitBold) {
            return UIFont(descriptor: descriptor, size: descriptor.pointSize)
        } else {
            return baseFont
        }
    }

    public var italic: UIFont {
        if let descriptor = baseFont.fontDescriptor.withSymbolicTraits(.traitItalic) {
            return UIFont(descriptor: descriptor, size: descriptor.pointSize)
        } else {
            return baseFont
        }
    }

    public var boldItalic: UIFont {
        if let descriptor = baseFont.fontDescriptor.withSymbolicTraits([.traitItalic, .traitBold]) {
            return UIFont(descriptor: descriptor, size: descriptor.pointSize)
        } else {
            return baseFont
        }
    }

    public var monospaced: UIFont {
        UIFont(descriptor: monospacedFont.fontDescriptor, size: monospacedFont.pointSize)
    }

    public var headingFonts: HeadingFonts {
        .init(
            h1: .boldSystemFont(ofSize: baseFont.pointSize * 1.50),
            h2: .boldSystemFont(ofSize: baseFont.pointSize * 1.40),
            h3: .boldSystemFont(ofSize: baseFont.pointSize * 1.25),
            h4: .boldSystemFont(ofSize: baseFont.pointSize * 1.15),
            h5: .boldSystemFont(ofSize: baseFont.pointSize * 1.10),
            h6: .boldSystemFont(ofSize: baseFont.pointSize * 1.05)
        )
    }

    public init(
        baseFont: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize),
        monospacedFont: UIFont? = UIFont(name: "Menlo-Regular", size: UIFont.systemFontSize)
    ) {
        self.baseFont = baseFont
        self.monospacedFont = monospacedFont ?? baseFont
    }
}
