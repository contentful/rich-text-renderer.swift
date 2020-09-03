// RichTextRenderer

import UIKit

final class ConcreteTextContainer: NSTextContainer {

    private var lineFragmentProviders = [LineFragmentProviding]()

    override func lineFragmentRect(
        forProposedRect proposedRect: CGRect,
        at characterIndex: Int,
        writingDirection baseWritingDirection: NSWritingDirection,
        remaining remainingRect: UnsafeMutablePointer<CGRect>?
    ) -> CGRect {
        let lineFragmentRect = super.lineFragmentRect(
            forProposedRect: proposedRect,
            at: characterIndex,
            writingDirection: baseWritingDirection,
            remaining: remainingRect
        )

        guard let textStorage = layoutManager?.textStorage else { return lineFragmentRect }

        for provider in lineFragmentProviders {
            if let proposedLineFragmentRect = provider.lineFragmentRect(
                forProposedRect: lineFragmentRect,
                at: characterIndex,
                writingDirection: baseWritingDirection,
                remaining: remainingRect,
                textStorage: textStorage
            ) {
                return proposedLineFragmentRect
            }
        }

        return lineFragmentRect
    }

    func add(provider: LineFragmentProviding) {
        lineFragmentProviders.append(provider)
    }
}
