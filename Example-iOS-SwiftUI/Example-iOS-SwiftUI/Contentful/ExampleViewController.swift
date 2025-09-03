// Example-iOS-SwiftUI

import SwiftUI
import UIKit
import Contentful
import ContentfulRichTextRenderer

final class ExampleViewController: RichTextViewController {
    private let client = ContentfulService()

    init() {
        var configuration = DefaultRendererConfiguration()
        configuration.resourceLinkBlockViewProvider = ExampleBlockViewProvider()
        configuration.resourceLinkInlineStringProvider = ExampleInlineStringProvider()

        let renderersProvider = DefaultRenderersProvider()

        let renderer = RichTextDocumentRenderer(
            configuration: configuration,
            nodeRenderers: renderersProvider
        )

        super.init(renderer: renderer)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        fetchContent()
    }

    private func fetchContent() {
        client.fetchArticle { [weak self] result in
            switch result {
            case .success(let article):
                self?.richTextDocument = article.content
            case .failure(let error):
                print("Contentful error:", error)
            }
        }
    }
}
