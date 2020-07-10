// RichTextRenderer

import UIKit

protocol DecorationRendering {
    func draw(in context: CGContext, boundingRect: CGRect, textContainer: NSTextContainer)
}
