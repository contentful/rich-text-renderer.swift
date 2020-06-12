// RichTextRenderer

import CoreGraphics

/// View that can be used to represent unsupported `ResourceLinkBlock` nodes.
public final class EmptyResourceLinkBlockView: View, ResourceLinkBlockViewRepresentable {
    public var surroundingTextShouldWrap: Bool = true
    public var context: [CodingUserInfoKey: Any] = [:]

    public func layout(with width: CGFloat) {}
}
