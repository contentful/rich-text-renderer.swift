// Example-iOS-SwiftUI

import Contentful

final class Cat: Resource, EntryDecodable, FieldKeysQueryable {
    enum FieldKeys: String, CodingKey {
        case name
    }

    static let contentTypeId = "cat"

    let sys: Sys
    let name: String

    public required init(from decoder: Decoder) throws {
        sys = try decoder.sys()
        
        let fields = try decoder.contentfulFieldsContainer(keyedBy: FieldKeys.self)
        name = try fields.decode(String.self, forKey: .name)
    }
}
