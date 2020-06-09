// ContentfulRichTextRenderer

import Contentful

public protocol ResourceLinkBlockViewProviding {
    /// Creates a custom view representing `ResourceLinkBlock` node.
    func view(
        for resource: FlatResource,
        context: [CodingUserInfoKey: Any]
    ) -> ResourceLinkBlockViewRepresentable
}
