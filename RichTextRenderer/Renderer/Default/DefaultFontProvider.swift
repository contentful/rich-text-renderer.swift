// RichTextRenderer

public struct DefaultFontProvider: FontProviding {
    private let font: Font

    public var regular: Font {
        font
    }

    public var bold: Font {
        if let descriptor = font.fontDescriptor.withSymbolicTraits(.traitBold) {
            return Font(descriptor: descriptor, size: descriptor.pointSize)
        } else {
            return font
        }
    }

    public var italic: Font {
        if let descriptor = font.fontDescriptor.withSymbolicTraits(.traitItalic) {
            return Font(descriptor: descriptor, size: descriptor.pointSize)
        } else {
            return font
        }
    }

    public var boldItalic: Font {
        if let descriptor = font.fontDescriptor.withSymbolicTraits([.traitItalic, .traitBold]) {
            return Font(descriptor: descriptor, size: descriptor.pointSize)
        } else {
            return font
        }
    }

    public var code: Font {
        Font(name: "Menlo-Regular", size: font.pointSize) ?? font
    }

    public init(font: Font = Font.systemFont(ofSize: Font.systemFontSize)) {
        self.font = font
    }
}
