// Example-iOS-SwiftUI

import Contentful

final class ContentfulService {
    private let client: Client

    init() {
        self.client = Client(
            spaceId: "9udmtmq3klnj",
            accessToken: "QghA6Rja4xNLKWAvrXhZiEtE8XuazE8c4XLwrvwOT-8",
            contentTypeClasses: [
                Article.self,
                Car.self,
                Cat.self
            ]
        )
    }

    func fetchArticle(completion: @escaping (Result<Article, Error>) -> Void) {
        self.client.fetch(Article.self, id: "59XJArAv7bhLikabR9qnOR", then: completion)
    }
}
