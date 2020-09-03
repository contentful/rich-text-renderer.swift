// RichTextRenderer

import Foundation

public extension NSMutableAttributedString {
    static func makeNewLineString() -> NSMutableAttributedString {
        return .init(string: "\n")
    }
}
