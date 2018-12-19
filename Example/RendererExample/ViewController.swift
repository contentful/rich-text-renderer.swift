//
//  ViewController.swift
//  RendererExample
//
//  Created by JP Wright on 22.11.17.
//  Copyright © 2017 Contentful. All rights reserved.
//

import UIKit
import Contentful
import ContentfulRichTextRenderer

final class MarkdownContentType: Resource, EntryDecodable, FieldKeysQueryable {
    static let contentTypeId = "markdownContentType"

    let sys: Sys
    let markdownBody: String
    let name: String

    public required init(from decoder: Decoder) throws {
        sys = try decoder.sys()
        let fields = try decoder.contentfulFieldsContainer(keyedBy: FieldKeys.self)
        markdownBody = try fields.decode(String.self, forKey: .markdownBody)
        name = try fields.decode(String.self, forKey: .name)
    }

    enum FieldKeys: String, CodingKey {
        case name, markdownBody
    }
}


final class STTest: Resource, EntryDecodable, FieldKeysQueryable {
    
    static let contentTypeId = "stTest"

    let sys: Sys
    let name: String
    let body: RichTextDocument

    public required init(from decoder: Decoder) throws {
        sys = try decoder.sys()
        let fields = try decoder.contentfulFieldsContainer(keyedBy: FieldKeys.self)
        name = try fields.decode(String.self, forKey: .name)
        body = try fields.decode(RichTextDocument.self, forKey: .body)
    }

    enum FieldKeys: String, CodingKey {
        case name, body
    }
}

final class EmbeddedEntry: Resource, EntryDecodable, FieldKeysQueryable {

    static let contentTypeId = "embedded"

    let sys: Sys
    let body: String

    public required init(from decoder: Decoder) throws {
        sys = try decoder.sys()
        let fields = try decoder.contentfulFieldsContainer(keyedBy: FieldKeys.self)
        body = try fields.decode(String.self, forKey: .body)
    }

    enum FieldKeys: String, CodingKey {
        case body
    }
}

class EmbeddedTextView: UITextView, ResourceLinkBlockRepresentable {
    var surroundingTextShouldWrap: Bool = true
    var context: [CodingUserInfoKey: Any] = [:]

    func layout(with width: CGFloat) {
        frame.size = sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
    }
}

struct MyInlineProvider: InlineProvider {
    func string(for resource: FlatResource, context: [CodingUserInfoKey: Any]) -> NSMutableAttributedString {
        if let embedded = resource as? EmbeddedEntry {
            let url = URL(string: "https://example.com/\(embedded.id)")!
            return NSMutableAttributedString(string: embedded.body, attributes: [.link: url])
        } else if let asset = resource as? Asset, let title = asset.title, let url = asset.url {
            return NSMutableAttributedString(string: title, attributes: [.link: url])
        }
        return NSMutableAttributedString(string: "")
    }
}

struct MyViewProvider: ViewProvider {
    func view(for resource: FlatResource, context: [CodingUserInfoKey: Any]) -> ResourceBlockView {
        if let embedded = resource as? EmbeddedEntry {
            let view = EmbeddedTextView(frame: .zero)
            view.context = context

            view.surroundingTextShouldWrap = false

            view.backgroundColor = .gray
            view.textColor = .black
            view.text = embedded.body

            view.sizeToFit()
            return view
        } else if let markdownType = resource as? MarkdownContentType {
            let view = EmbeddedTextView(frame: .zero)
            view.context = context

            let listContext = context[.listContext] as! ListContext
            view.surroundingTextShouldWrap = listContext.level == 0

            view.backgroundColor = .gray
            view.textColor = .black
            view.text = markdownType.markdownBody

            view.sizeToFit()
            return view
        } else if let asset = resource as? Asset, asset.file?.details?.imageInfo != nil {
            let imageView = EmbeddedAssetImageView(asset: asset)
            let listContext = context[.listContext] as! ListContext
            imageView.surroundingTextShouldWrap = listContext.level == 0
            imageView.backgroundColor = .gray
            imageView.setImageToNaturalHeight()
            // For snapshot testing.
            imageView.isAccessibilityElement = true
            imageView.accessibilityLabel = asset.title
            return imageView
        }
        return EmptyView(frame: .zero)
    }
}


class ViewController: RichTextViewController {

    init() {
        var styling = RenderingConfiguration()
        styling.viewProvider = MyViewProvider()
        styling.inlineResourceProvider = MyInlineProvider()
        let renderer = DefaultRichTextRenderer(styleConfig: styling)
        super.init(richText: nil, renderer: renderer, nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let client = Client(spaceId: "jd7yc4wnatx3",
                        accessToken: "6256b8ef7d66805ca41f2728271daf27e8fa6055873b802a813941a0fe696248",
                        contentTypeClasses: [STTest.self, EmbeddedEntry.self, MarkdownContentType.self])

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        if richText == nil {
            let query = QueryOn<STTest>.where(sys: .id, .equals("6tVjZ7i66QOSsi66KykGsk"))
            client.fetchArray(of: STTest.self,
                              matching: query) { [unowned self] result in
                switch result {
                case .success(let arrayResponse):
                    self.richText = arrayResponse.items.first!.body

                case .error(let error):
                    print("\(error)")
                    }
            }
        }
    }
}

