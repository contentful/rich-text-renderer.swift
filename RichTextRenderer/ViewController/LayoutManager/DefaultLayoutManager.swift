// RichTextRenderer

import UIKit

/// Layout manager that renders decorations around specific nodes.
public class DefaultLayoutManager: NSLayoutManager {
    var blockQuoteDecorationRenderer: DecorationRendering!

    public override init() {
        super.init()
        allowsNonContiguousLayout = true
    }

    public override var hasNonContiguousLayout: Bool {
        return true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func drawBackground(
        forGlyphRange glyphsToShow: NSRange,
        at origin: CGPoint
    ) {
        super.drawBackground(forGlyphRange: glyphsToShow, at: origin)

        let characterRange = self.characterRange(
            forGlyphRange: glyphsToShow,
            actualGlyphRange: nil
        )

        textStorage?.enumerateAttributes(
            in: characterRange,
            options: []
        ) { attributes, attributesRange, _ in
            guard let textContainer = textContainers.first else { return }

            let glyphRange = self.glyphRange(
                forCharacterRange: attributesRange,
                actualCharacterRange: nil
            )

            let boundingRect = self.boundingRect(
                forGlyphRange: glyphRange,
                in: textContainer
            )

            guard let context = UIGraphicsGetCurrentContext() else { return }

            if attributes[.block] != nil {
                assert(blockQuoteDecorationRenderer != nil, "The renderer must not be nil.")
                blockQuoteDecorationRenderer?.draw(
                    in: context,
                    boundingRect: boundingRect,
                    textContainer: textContainer
                )
            }
        }
    }
}
