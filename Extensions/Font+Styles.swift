// ContentfulRichTextRenderer

public extension Font {

    /// Returns a bolded version of the current font, or `nil` if not available.
    func bolded() -> Font? {
        if let descriptor = fontDescriptor.withSymbolicTraits(.traitBold) {
            return Font(descriptor: descriptor, size: pointSize)
        }
        return nil
    }

    /// Returns a italicized version of the current font, or `nil` if not available.
    func italicized() -> Font? {
        if let descriptor = fontDescriptor.withSymbolicTraits(.traitItalic) {
            return Font(descriptor: descriptor, size: pointSize)
        }
        return nil
    }

    /// Returns `Menlo-Regular` font, as it's one of the only 2 monospaced fonts available on iOS.
    func monospaced() -> Font? {
        return Font(name: "Menlo-Regular", size: pointSize)
    }

    /// Returns an italicized and bolded version of the current font, or `nil` if not available.
    func italicizedAndBolded() -> Font? {
        if let descriptor = fontDescriptor.withSymbolicTraits([.traitItalic, .traitBold]) {
            return Font(descriptor: descriptor, size: pointSize)
        }
        return nil
    }
}
