//
//  ViewController.swift
//  TestPodInstall
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

public class EmbeddedAssetImageView: UIImageView, ResourceLinkBlockRepresentable {

    public var surroundingTextShouldWrap: Bool = true
    public var context: [CodingUserInfoKey: Any] = [:]

    var asset: Asset!

    public func layout(with width: CGFloat) {
        // Get the current width of the cell and see if it is wider than the screen.
        guard let assetWidth = asset.file?.details?.imageInfo?.width else { return }
        guard let assetHeight = asset.file?.details?.imageInfo?.height else { return }

        let aspectRatio = assetWidth / assetHeight

        frame.size.width = width
        frame.size.height = width / CGFloat(aspectRatio)
    }

    func setImageToNaturalHeight(fromAsset asset: Asset,
                                 additionalOptions: [ImageOption] = []) {

        // Get the current width of the cell and see if it is wider than the screen.
        guard let width = asset.file?.details?.imageInfo?.width else { return }
        guard let height = asset.file?.details?.imageInfo?.height else { return }

        // Use scale to get the pixel size of the image view.
        let scale = UIScreen.main.scale

        let viewWidthInPx = Double(UIScreen.main.bounds.width * scale)
        let percentageDifference = viewWidthInPx / width

        let viewHeightInPoints = height * percentageDifference / Double(scale)
        let viewHeightInPx = viewHeightInPoints * Double(scale)

        frame.size = CGSize(width: UIScreen.main.bounds.width, height: CGFloat(viewHeightInPoints))

        let imageOptions: [ImageOption] = [
            .formatAs(.jpg(withQuality: .asPercent(100))),
            .width(UInt(viewWidthInPx)),
            .height(UInt(viewHeightInPx)),
            ] + additionalOptions

        let url = try! asset.url(with: imageOptions)

        // Use AlamofireImage extensons to fetch the image and render the image veiw.
        af_setImage(withURL: url,
                    placeholderImage: nil,
                    imageTransition: .crossDissolve(0.5),
                    runImageTransitionIfCached: true)
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
            let imageView = EmbeddedAssetImageView(frame: .zero)
            let listContext = context[.listContext] as! ListContext
            imageView.surroundingTextShouldWrap = listContext.level == 0
            imageView.asset = asset
            imageView.backgroundColor = .gray
            imageView.setImageToNaturalHeight(fromAsset: asset)
            return imageView
        }
        return EmptyView(frame: .zero)
    }
}


class ViewController: RichTextViewController {

    init() {
        var styling = Styling()
        styling.viewProvider = MyViewProvider()
        styling.inlineResourceProvider = MyInlineProvider()
        let renderer = DefaultRichTextRenderer(styling: styling)
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

        let query = QueryOn<STTest>.where(sys: .id, .equals("6tVjZ7i66QOSsi66KykGsk"))
        client.fetchArray(of: STTest.self,
                          matching: query) { [unowned self] result in
            switch result {
            case .success(let arrayResponse):

                let output = self.renderer.render(document: arrayResponse.items.first!.body)
                print("network call done")
                DispatchQueue.main.async {
                    self.textStorage.beginEditing()
                    self.textStorage.setAttributedString(output)
                    self.textStorage.endEditing()
                }

            case .error(let error):
                print("\(error)")
            }
        }
    }
}

