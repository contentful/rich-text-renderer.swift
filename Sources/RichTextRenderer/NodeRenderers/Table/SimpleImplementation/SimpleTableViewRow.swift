import Foundation
import UIKit

class SimpleTableViewRow: UIStackView {
    init(cells: [UIView]) {
        super.init(frame: .zero)
        axis = .horizontal
        distribution = .fillEqually
        layer.borderWidth = 0.5
        layer.borderColor = UIColor(red: 177/255,
                                    green: 193/255,
                                    blue: 203/255,
                                    alpha: 1).cgColor
        layer.masksToBounds = true
        for cell in cells {
            addArrangedSubview(cell)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
