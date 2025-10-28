import Foundation
import Contentful
import UIKit

class SimpleTableViewCell: UIView, ResourceLinkBlockViewRepresentable {
    var context: [CodingUserInfoKey: Any] = [:]

    private let richTextViewController: RichTextViewController
    private var measuredWidth: CGFloat = 0
    private var measuredHeight: CGFloat = 0

    func layout(with width: CGFloat) {
        guard width > 0 else {
            measuredWidth = 0
            measuredHeight = 0
            invalidateIntrinsicContentSize()
            return
        }

        // Now measure the required height
        // systemLayoutSizeFitting will give us the best-fit size given the constraints.
        let fittingSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let calculatedSize = richTextViewController.view.systemLayoutSizeFitting(
            fittingSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        measuredWidth = width
        measuredHeight = ceil(calculatedSize.height)
        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: measuredWidth, height: measuredHeight)
    }

    init(isHeader: Bool, nodes: [Node]) {
        let configuration = DefaultRendererConfiguration()
        let renderer = RichTextDocumentRenderer(configuration: configuration)
        richTextViewController = RichTextViewController(renderer: renderer, isScrollEnabled: false)

        super.init(frame: .zero)

        layer.borderColor = UIColor(red: 177/255, green: 193/255, blue: 203/255, alpha: 1).cgColor
        layer.borderWidth = 0.5
        backgroundColor = isHeader
            ? UIColor(red: 232/255, green: 235/255, blue: 238/255, alpha: 1)
            : .clear

        addSubview(richTextViewController.view)
        richTextViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            richTextViewController.view.topAnchor.constraint(equalTo: topAnchor),
            richTextViewController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
            richTextViewController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            richTextViewController.view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        if isHeader {
            richTextViewController.view.overrideUserInterfaceStyle = .light
        }

        richTextViewController.richTextDocument = RichTextDocument(content: nodes)
        richTextViewController.updateTextViewBackground(color: .clear)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
