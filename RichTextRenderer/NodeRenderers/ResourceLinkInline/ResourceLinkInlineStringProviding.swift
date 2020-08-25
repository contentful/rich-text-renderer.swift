// RichTextRenderer

import Contentful

public protocol ResourceLinkInlineStringProviding {
    /// Creates a custom string representing `ResourceLinkInline` node.
    func string(
        for resource: Link,
        context: [CodingUserInfoKey: Any]
    ) -> NSMutableAttributedString
}
