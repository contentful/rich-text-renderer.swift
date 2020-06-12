// RichTextRenderer

import Contentful

/// Default implementation of the `ResourceLinkBlockViewProviding` that provides an empty view.
public struct EmptyResourceLinkBlockViewProvider: ResourceLinkBlockViewProviding {
    public func view(
        for resource: Link,
        context: [CodingUserInfoKey: Any]
    ) -> ResourceLinkBlockViewRepresentable {
        EmptyResourceLinkBlockView()
    }
}
