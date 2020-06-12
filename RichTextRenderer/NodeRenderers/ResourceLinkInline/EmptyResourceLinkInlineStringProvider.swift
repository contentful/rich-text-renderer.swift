// RichTextRenderer

import Contentful

/// Default `ResourceLinkInlineStringProvider` which return an empty string.
final class EmptyResourceLinkInlineStringProvider: ResourceLinkInlineStringProviding {
    func string(
        for resource: FlatResource,
        context: [CodingUserInfoKey : Any]
    ) -> NSMutableAttributedString {
        NSMutableAttributedString(string: "")
    }
}
