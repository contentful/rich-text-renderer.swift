public protocol StyleProviding {

    /// Base version of the font.
    var regular: UIFont { get }
    var regularColor: UIColor { get }

    var bold: UIFont { get }
    var boldColor: UIColor { get }

    var italic: UIFont { get }
    var italicColor: UIColor { get }

    var boldItalic: UIFont { get }
    var boldItalicColor: UIColor { get }
    
    /// Base hyperlink color
    var hyperlinkColor: UIColor { get }

    /// Fonts and their colors used in heading nodes.
    var headingStyles: HeadingStyles { get }

    /// Font and its color used to render code snippets (monospace).
    var monospaced: UIFont { get }
    var monospacedColor: UIColor { get }
}
