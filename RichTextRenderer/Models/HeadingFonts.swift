// ContentfulRichTextRenderer

/// Font definitions for headings.
public struct HeadingFonts {
    let h1: Font
    let h2: Font
    let h3: Font
    let h4: Font
    let h5: Font
    let h6: Font

    public init(
        h1: Font,
        h2: Font,
        h3: Font,
        h4: Font,
        h5: Font,
        h6: Font
    ) {
        self.h1 = h1
        self.h2 = h2
        self.h3 = h3
        self.h4 = h4
        self.h5 = h5
        self.h6 = h6
    }

    func font(for level: HeadingLevel) -> Font {
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
