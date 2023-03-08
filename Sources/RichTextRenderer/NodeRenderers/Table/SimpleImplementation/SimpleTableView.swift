import Foundation
import UIKit

class SimpleTableView: UIScrollView {
    
    init(rows: [UIView]) {
        super.init(frame: .zero)
        isScrollEnabled = false
        let stackView = UIStackView(arrangedSubviews: rows)
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: frameLayoutGuide.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: frameLayoutGuide.trailingAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor).isActive = true
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 177/255,
                                    green: 193/255,
                                    blue: 203/255,
                                    alpha: 1).cgColor
        layer.masksToBounds = true
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
