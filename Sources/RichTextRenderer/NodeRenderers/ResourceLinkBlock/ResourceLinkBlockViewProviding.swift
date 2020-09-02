// RichTextRenderer

import Contentful

public protocol ResourceLinkBlockViewProviding {
    /// Creates a custom view representing `ResourceLinkBlock` node.
    func view(
        for resource: Link,
        context: [CodingUserInfoKey: Any]
    ) -> ResourceLinkBlockViewRepresentable?
}
