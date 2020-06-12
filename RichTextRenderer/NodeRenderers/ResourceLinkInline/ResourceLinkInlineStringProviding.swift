// RichTextRenderer

import Contentful

public protocol ResourceLinkInlineStringProviding {
    /// Creates a custom string representing `ResourceLinkInline` node.
    func string(
        for resource: FlatResource,
        context: [CodingUserInfoKey: Any]
    ) -> NSMutableAttributedString
}
