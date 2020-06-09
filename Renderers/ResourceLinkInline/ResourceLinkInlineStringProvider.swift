// ContentfulRichTextRenderer

import Contentful

/// Default `ResourceLinkInlineStringProvider` which return an empty string.
final class ResourceLinkInlineStringProvider: ResourceLinkInlineStringProviding {
    func string(
        for resource: FlatResource,
        context: [CodingUserInfoKey : Any]
    ) -> NSMutableAttributedString {
        NSMutableAttributedString(string: "")
    }
}
