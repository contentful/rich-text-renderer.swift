// Example-iOS-SwiftUI

import Contentful

final class Car: Resource, EntryDecodable, FieldKeysQueryable {
    enum FieldKeys: String, CodingKey {
        case model
    }

    static let contentTypeId = "car"

    let sys: Sys
    let model: String

    public required init(from decoder: Decoder) throws {
        sys = try decoder.sys()

        let fields = try decoder.contentfulFieldsContainer(keyedBy: FieldKeys.self)
        model = try fields.decode(String.self, forKey: .model)
    }
}
