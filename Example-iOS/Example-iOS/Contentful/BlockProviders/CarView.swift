// Example-iOS

import ContentfulRichTextRenderer
import UIKit

final class CarView: UIView, ResourceLinkBlockViewRepresentable {
    private let car: Car

    var surroundingTextShouldWrap: Bool = false
    var context: [CodingUserInfoKey: Any]

    public init(car: Car, context: [CodingUserInfoKey: Any] = [:]) {
        self.car = car
        self.context = context
        super.init(frame: .zero)

        let title = UILabel(frame: .zero)
        title.text = "🚗 " + car.model + " 🚗"
        title.translatesAutoresizingMaskIntoConstraints = false
        addSubview(title)

        title.topAnchor.constraint(equalTo: topAnchor).isActive = true
        title.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        title.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        title.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        title.sizeToFit()

        frame = title.bounds
        backgroundColor = .lightGray
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layout(with width: CGFloat) {}
}
