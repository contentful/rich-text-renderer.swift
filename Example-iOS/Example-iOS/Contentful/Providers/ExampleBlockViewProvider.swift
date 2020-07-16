// Example-iOS

import Contentful
import ContentfulRichTextRenderer
import UIKit

struct ExampleBlockViewProvider: ResourceLinkBlockViewProviding {
    func view(for resource: Link, context: [CodingUserInfoKey: Any]) -> ResourceLinkBlockViewRepresentable? {
        switch resource {
        case .entryDecodable(let entryDecodable):
            if let car = entryDecodable as? Car {
                return CarView(car: car)
            }

            return nil

        case .entry:
            return nil

        case .asset(let asset):
            guard asset.file?.details?.imageInfo != nil else { return nil }

            let imageView = ResourceLinkBlockImageView(asset: asset)

            imageView.backgroundColor = .gray
            imageView.setImageToNaturalHeight()
            return imageView

        default:
            return nil
        }
    }
}

final class CarView: UIView, ResourceLinkBlockViewRepresentable {
    private let car: Car

    var surroundingTextShouldWrap: Bool = false
    var context: [CodingUserInfoKey : Any] = [:]

    public init(car: Car) {
        self.car = car
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
