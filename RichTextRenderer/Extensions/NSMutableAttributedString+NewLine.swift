// RichTextRenderer

import Foundation

extension NSMutableAttributedString {
    static func makeNewLineString() -> NSMutableAttributedString {
        return .init(string: "\n")
    }
}
