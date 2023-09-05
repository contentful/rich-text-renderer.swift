import UIKit

public final class DefaultStyleProvider: StyleProviding {
    private let baseFont: UIFont
    private let monospacedFont: UIFont
    private let baseColor: UIColor
    private let baseHyperlinkColor: UIColor

    public var regular: UIFont {
        return UIFont(descriptor: baseFont.fontDescriptor, size: baseFont.pointSize)
    }

    public var regularColor: UIColor {
        return baseColor
    }

    public var bold: UIFont {
        if let descriptor = baseFont.fontDescriptor.withSymbolicTraits(.traitBold) {
            return UIFont(descriptor: descriptor, size: descriptor.pointSize)
        } else {
            return baseFont
        }
    }

    public var boldColor: UIColor {
        return baseColor
    }

    public var italic: UIFont {
        if let descriptor = baseFont.fontDescriptor.withSymbolicTraits(.traitItalic) {
            return UIFont(descriptor: descriptor, size: descriptor.pointSize)
        } else {
            return baseFont
        }
    }

    public var italicColor: UIColor {
        return baseColor
    }

    public var boldItalic: UIFont {
        if let descriptor = baseFont.fontDescriptor.withSymbolicTraits([.traitItalic, .traitBold]) {
            return UIFont(descriptor: descriptor, size: descriptor.pointSize)
        } else {
            return baseFont
        }
    }

    public var boldItalicColor: UIColor {
        return baseColor
    }

    public var monospaced: UIFont {
        UIFont(descriptor: monospacedFont.fontDescriptor, size: monospacedFont.pointSize)
    }

    public var monospacedColor: UIColor {
        return baseColor
    }

    public var headingStyles: HeadingStyles {
        .init(
            h1: .boldSystemFont(ofSize: baseFont.pointSize * 1.50), h1Color: baseColor,
            h2: .boldSystemFont(ofSize: baseFont.pointSize * 1.40), h2Color: baseColor,
            h3: .boldSystemFont(ofSize: baseFont.pointSize * 1.25), h3Color: baseColor,
            h4: .boldSystemFont(ofSize: baseFont.pointSize * 1.15), h4Color: baseColor,
            h5: .boldSystemFont(ofSize: baseFont.pointSize * 1.10), h5Color: baseColor,
            h6: .boldSystemFont(ofSize: baseFont.pointSize * 1.05), h6Color: baseColor
        )
    }
    
    public var hyperlinkColor: UIColor {
        return baseHyperlinkColor
    }

    public init(
        baseFont: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize),
        baseColor: UIColor = UIColor.black, // Base color initialization
        monospacedFont: UIFont? = UIFont(name: "Menlo-Regular", size: UIFont.systemFontSize),
        hyperlinkColor: UIColor? = UIColor.systemBlue
    ) {
        self.baseFont = baseFont
        self.baseColor = baseColor // Base color setup
        self.monospacedFont = monospacedFont ?? baseFont
        self.baseHyperlinkColor = hyperlinkColor ?? .systemBlue
    }
}
