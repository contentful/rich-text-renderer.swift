// Example-iOS

import Contentful
import RichTextRenderer
import UIKit

class ViewController: RichTextViewController {
    private let client = ContentfulService()

    init() {
        var configuration = DefaultRendererConfiguration()
        configuration.resourceLinkBlockViewProvider = ExampleViewProvider()
        let renderer = RichTextRenderer(configuration: configuration)
        
        super.init(richText: nil, renderer: renderer, nibName: nil, bundle: nil)
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
                self?.richText = article.content

            case .failure(let error):
                print(error)
            }
        }
    }
}

