// Example-iOS

import Contentful

final class ContentfulService {
    private let client: Client

    init() {
        self.client = Client(
            spaceId: "9udmtmq3klnj",
            accessToken: "QghA6Rja4xNLKWAvrXhZiEtE8XuazE8c4XLwrvwOT-8",
            contentTypeClasses: [
                Article.self
            ]
        )
    }

    func fetchArticle(completion: @escaping (Result<Article, Error>) -> Void) {
        self.client.fetch(Article.self, id: "Znv9fEW0y0XVyrkcO8Xq5", then: completion)
    }
}
