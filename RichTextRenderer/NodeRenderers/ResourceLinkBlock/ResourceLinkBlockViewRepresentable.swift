// RichTextRenderer

import UIKit

/// Represents view with `ResourceLinkBlock` content.
public protocol ResourceLinkBlockViewRepresentable: UIView {
    /// Passed-in context. Useful for determining rendering logic.
    var context: [CodingUserInfoKey: Any] { get set }

    /// Layout the view based on the provided params.
    func layout(with width: CGFloat)
}
