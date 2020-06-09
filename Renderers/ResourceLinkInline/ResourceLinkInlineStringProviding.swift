// ContentfulRichTextRenderer

import Contentful

/// Creates a custom string representing `ResourceLinkInline` node.
public protocol ResourceLinkInlineStringProviding {
    func string(
        for resource: FlatResource,
        context: [CodingUserInfoKey: Any]
    ) -> NSMutableAttributedString
}
