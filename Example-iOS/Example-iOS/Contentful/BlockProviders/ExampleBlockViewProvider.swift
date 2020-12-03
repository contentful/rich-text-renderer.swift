// Example-iOS

import Contentful
import ContentfulRichTextRenderer
import UIKit

struct ExampleBlockViewProvider: ResourceLinkBlockViewProviding {
    func view(for resource: Link, context: [CodingUserInfoKey: Any]) -> ResourceLinkBlockViewRepresentable? {
        switch resource {
        case .entryDecodable(let entryDecodable):
            if let car = entryDecodable as? Car {
                return CarView(car: car, context: context)
            } else if let article = entryDecodable as? Article {
                return SuggestedArticleView(article: article, context: context)
            }

            return nil

        case .entry:
            return nil

        case .asset(let asset):
            guard asset.file?.details?.imageInfo != nil else { return nil }

            let imageView = ResourceLinkBlockImageView(asset: asset, context: context)

            imageView.backgroundColor = .gray
            imageView.setImageToNaturalHeight()
            return imageView

        default:
            return nil
        }
    }
}
