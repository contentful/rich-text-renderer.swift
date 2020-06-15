// RichTextRenderer

/// Provides different font styles.
public protocol FontProviding {

    /// Base version of the font.
    var regular: Font { get }

    var bold: Font { get }
    var italic: Font { get }
    var boldItalic: Font { get }

    /// Font used to render code snippets (monospace).
    var code: Font { get }
}
