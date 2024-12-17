import Foundation
import UIKit

class SimpleTableViewRow: UIView, ResourceLinkBlockViewRepresentable {
    var context: [CodingUserInfoKey : Any] = [:]

    private var cells: [SimpleTableViewCell]
    private let stackView = UIStackView()
    private var measuredWidth: CGFloat = 0
    private var measuredHeight: CGFloat = 0

    func layout(with width: CGFloat) {
        guard width > 0 && !cells.isEmpty else {
            measuredWidth = 0
            measuredHeight = 0
            invalidateIntrinsicContentSize()
            return
        }

        let cellWidth = width / CGFloat(cells.count)
        var maxHeight: CGFloat = 0

        for cell in cells {
            cell.layout(with: cellWidth)
            let cellHeight = cell.intrinsicContentSize.height
            if cellHeight > maxHeight {
                maxHeight = cellHeight
            }
        }

        measuredWidth = width
        measuredHeight = maxHeight
        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        // Return the measured width and height
        return CGSize(width: measuredWidth, height: measuredHeight)
    }

    init(cells: [SimpleTableViewCell]) {
        self.cells = cells
        super.init(frame: .zero)

        setContentCompressionResistancePriority(.required, for: .vertical)

        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.distribution = .fillEqually

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        for cell in cells {
            stackView.addArrangedSubview(cell)
        }

        layer.borderWidth = 0.5
        layer.borderColor = UIColor(red: 177/255, green: 193/255, blue: 203/255, alpha: 1).cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
