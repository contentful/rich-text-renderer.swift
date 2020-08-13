// Example-iOS

import ContentfulRichTextRenderer
import UIKit

final class SuggestedArticleView: UIView, ResourceLinkBlockViewRepresentable {

    private enum Constant {
        static let padding: CGFloat = 12.0
    }

    private let article: Article
    private var imageView: UIImageView!
    private var title: UILabel!

    var context: [CodingUserInfoKey : Any] = [:]

    public init(article: Article) {
        self.article = article
        super.init(frame: .init(x: 0, y: 0, width: 1, height: 1))

        imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.rtrSystemBackground
        addSubview(imageView)

        imageView.topAnchor.constraint(
            equalTo: topAnchor,
            constant: Constant.padding
        ).isActive = true

        imageView.bottomAnchor.constraint(
            lessThanOrEqualTo: bottomAnchor,
            constant: -Constant.padding
        ).isActive = true

        imageView.leadingAnchor.constraint(
            equalTo: leadingAnchor,
            constant: Constant.padding
        ).isActive = true

        imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true

        title = UILabel(frame: .zero)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = article.title
        title.textColor = UIColor.black
        title.numberOfLines = 0
        addSubview(title)

        title.topAnchor.constraint(
            equalTo: topAnchor,
            constant: Constant.padding
        ).isActive = true

        title.trailingAnchor.constraint(
            equalTo: trailingAnchor,
            constant: -Constant.padding
        ).isActive = true

        title.bottomAnchor.constraint(
            lessThanOrEqualTo: bottomAnchor,
            constant: -Constant.padding
        ).isActive = true

        title.leadingAnchor.constraint(
            equalTo: imageView.trailingAnchor,
            constant: Constant.padding
        ).isActive = true

        backgroundColor = UIColor.white
        layer.shadowColor = UIColor.rtrLabel.cgColor
        layer.shadowOffset = .init(width: 4, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.25

        if let imageUrl = article.thumbnail?.url {
            imageView.af.setImage(withURL: imageUrl)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layout(with width: CGFloat) {
        layoutIfNeeded()

        var rect = frame
        rect.size.width = width

        let titleSize = title.sizeThatFits(.init(width: title.bounds.width, height: .infinity))
        let titleHeight = titleSize.height
        let imageHeight = imageView.frame.height

        rect.size.height = max(titleHeight, imageHeight) + 2 * Constant.padding
        self.frame = rect
    }
}

