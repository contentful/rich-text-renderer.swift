// RichTextRenderer

import UIKit

/// Provides different font styles.
public protocol FontProviding {

    /// Base version of the font.
    var regular: UIFont { get }

    var bold: UIFont { get }
    var italic: UIFont { get }
    var boldItalic: UIFont { get }

    /// Fonts used in heading nodes.
    var headingFonts: HeadingFonts { get }

    /// Font used to render code snippets (monospace).
    var monospaced: UIFont { get }
}
