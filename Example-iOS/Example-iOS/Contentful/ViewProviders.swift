// Example-iOS

import Contentful
import RichTextRenderer

struct ExampleViewProvider: ResourceLinkBlockViewProviding {
    func view(for resource: Link, context: [CodingUserInfoKey: Any]) -> ResourceLinkBlockViewRepresentable? {
        switch resource {
        case .entry:
            return nil

        case .asset(let asset):
            guard asset.file?.details?.imageInfo != nil else { return nil }

            let imageView = EmbeddedAssetImageView(asset: asset)
            let listContext = context[.listContext] as! ListContext
            imageView.surroundingTextShouldWrap = listContext.level == 0
            imageView.backgroundColor = .gray
            imageView.setImageToNaturalHeight()
            return imageView

        default:
            return nil
        }
    }
}
