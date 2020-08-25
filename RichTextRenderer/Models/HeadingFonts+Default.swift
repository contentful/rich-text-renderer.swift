// RichTextRenderer

public extension HeadingFonts {
    static var `default`: HeadingFonts {
        .init(
            h1: .systemFont(ofSize: 24, weight: .semibold),
            h2: .systemFont(ofSize: 18, weight: .semibold),
            h3: .systemFont(ofSize: 16, weight: .semibold),
            h4: .systemFont(ofSize: 15, weight: .semibold),
            h5: .systemFont(ofSize: 14, weight: .semibold),
            h6: .systemFont(ofSize: 13, weight: .semibold)
        )
    }
}
