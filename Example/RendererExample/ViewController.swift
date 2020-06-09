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
    
    static let contentTypeId = "article"

    let sys: Sys
    let title: String
    let content: RichTextDocument

    public required init(from decoder: Decoder) throws {
        sys = try decoder.sys()
        let fields = try decoder.contentfulFieldsContainer(keyedBy: FieldKeys.self)
        title = try fields.decode(String.self, forKey: .title)
        content = try fields.decode(RichTextDocument.self, forKey: .content)
    }

    enum FieldKeys: String, CodingKey {
        case title, content
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

class EmbeddedTextView: UITextView, ResourceLinkBlockViewRepresentable {
    var surroundingTextShouldWrap: Bool = true
    var context: [CodingUserInfoKey: Any] = [:]

    func layout(with width: CGFloat) {
        frame.size = sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
    }
}

struct MyInlineProvider: ResourceLinkInlineStringProviding {
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

struct MyViewProvider: ResourceLinkBlockViewProviding {
    func view(for resource: FlatResource, context: [CodingUserInfoKey: Any]) -> ResourceLinkBlockViewRepresentable {
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
            return imageView
        }

        return EmptyResourceLinkBlockView()
    }
}


class ViewController: RichTextViewController {

    init() {
        var styling = RendererConfiguration()
        styling.resourceLinkBlockViewProvider = MyViewProvider()
        styling.resourceLinkInlineStringProvider = MyInlineProvider()
        let renderer = DefaultRichTextRenderer(styleConfig: styling)
        super.init(richText: nil, renderer: renderer, nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let client = Client(spaceId: "9udmtmq3klnj",
                        accessToken: "QghA6Rja4xNLKWAvrXhZiEtE8XuazE8c4XLwrvwOT-8",
                        contentTypeClasses: [STTest.self, /*EmbeddedEntry.self, MarkdownContentType.self*/])

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        let query = QueryOn<STTest>.where(sys: .id, .equals("Znv9fEW0y0XVyrkcO8Xq5"))
        client.fetchArray(of: STTest.self,
                          matching: query) { [unowned self] result in
            switch result {
            case .success(let arrayResponse):
                self.richText = arrayResponse.items.first!.content

            case .error(let error):
                print("\(error)")
            }
        }
    }
}

