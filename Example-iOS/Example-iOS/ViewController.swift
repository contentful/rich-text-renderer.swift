// Example-iOS

import Contentful
import RichTextRenderer
import UIKit

class ViewController: RichTextViewController {
    private let client = ContentfulService()

    init() {
        var configuration = DefaultRendererConfiguration()
        configuration.resourceLinkBlockViewProvider = ExampleViewProvider()
        let renderer = RichTextDocumentRenderer(configuration: configuration)
        
        super.init(renderer: renderer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        fetchContent()
    }

    private func fetchContent() {
        client.fetchArticle { [weak self] result in
            switch result {
            case .success(let article):
                print(article)
                self?.richTextDocument = article.content

            case .failure(let error):
                print(error)
            }
        }
    }
}

