// Example-iOS-SwiftUI

import Contentful

final class Article: Resource, EntryDecodable, FieldKeysQueryable {
    enum FieldKeys: String, CodingKey {
        case title, content, thumbnail
    }

    static let contentTypeId = "article"

    let sys: Sys
    let title: String
    let content: RichTextDocument
    var thumbnail: Asset?

    public required init(from decoder: Decoder) throws {
        sys = try decoder.sys()
        
        let fields = try decoder.contentfulFieldsContainer(keyedBy: FieldKeys.self)
        title = try fields.decode(String.self, forKey: .title)
        content = try fields.decode(RichTextDocument.self, forKey: .content)

        try fields.resolveLink(forKey: .thumbnail, decoder: decoder) { [weak self] result in
            self?.thumbnail = result as? Asset
        }
    }
}
