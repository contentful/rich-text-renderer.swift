// RichTextRenderer

import CoreGraphics

/// Represents view with `ResourceLinkBlock` content.
public protocol ResourceLinkBlockViewRepresentable: View {
    /// Determines if text around the view should wrap along the sides or should continue below.
    var surroundingTextShouldWrap: Bool { get }

    /// Passed-in context. Useful for determining rendering logic.
    var context: [CodingUserInfoKey: Any] { get set }

    /// Layout the view based on the provided params.
    func layout(with width: CGFloat)
}
