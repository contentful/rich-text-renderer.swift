// RichTextRenderer

import Contentful

extension FontProviding {
    /// Return a font based on the `Text.Mark`.
    func font(for textNode: Text) -> Font {
        let markTypes = textNode.marks.map { $0.type }

        if markTypes.contains(.bold) && markTypes.contains(.italic) {
            return boldItalic
        } else if markTypes.contains(.bold) {
            return bold
        } else if markTypes.contains(.italic) {
            return italic
        } else if markTypes.contains(.code) {
            return code
        } else {
            return regular
        }
    }
}
