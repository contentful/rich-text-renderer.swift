// RichTextRenderer

import Contentful

/// Default implementation of the `ResourceLinkBlockViewProviding` that provides an empty view.
public struct EmptyResourceLinkBlockViewProvider: ResourceLinkBlockViewProviding {
    public func view(
        for resource: FlatResource,
        context: [CodingUserInfoKey: Any]
    ) -> ResourceLinkBlockViewRepresentable {
        EmptyResourceLinkBlockView()
    }
}
