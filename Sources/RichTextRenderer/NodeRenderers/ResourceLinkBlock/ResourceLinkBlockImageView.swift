// RichTextRenderer

import AlamofireImage
import Contentful
import UIKit

/// Default `Asset` view representable for image kind of asset.
public class ResourceLinkBlockImageView: UIImageView, ResourceLinkBlockViewRepresentable {

    private var asset: Asset
    public var context: [CodingUserInfoKey: Any] = [:]

    public init(asset: Asset) {
        self.asset = asset
        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func layout(with width: CGFloat) {
        guard let imageSize = asset.imageSize else { return }

        frame.size.width = width

        let aspectRatio = imageSize.width / imageSize.height
        frame.size.height = width / CGFloat(aspectRatio)
    }

    public func setImageToNaturalHeight(additionalOptions: [ImageOption] = []) {
        guard let imageSize = asset.imageSize else { return }

        // Use the view's actual display scale via traitCollection to support multi-window
        // environments (iPad Split View, Stage Manager) correctly, avoiding the deprecated
        // UIScreen.main API.
        let scale = traitCollection.displayScale

        // Use the container width already established by layout(with:), falling back to the
        // window bounds for cases where the view fills available width.
        let containerWidth: CGFloat = frame.size.width > 0
            ? frame.size.width
            : (window?.bounds.width ?? UIScreen.main.bounds.width)

        let viewWidthPixels = containerWidth * scale
        let percentageDifference = viewWidthPixels / imageSize.width

        let viewHeightInPoints = imageSize.height * percentageDifference / scale
        let viewHeightPixels = viewHeightInPoints * scale

        frame.size = CGSize(
            width: containerWidth,
            height: viewHeightInPoints
        )

        let imageOptions: [ImageOption] = [
            .formatAs(.jpg(withQuality: .asPercent(100))),
            .width(UInt(viewWidthPixels)),
            .height(UInt(viewHeightPixels)),
        ] + additionalOptions

        guard let url = try? asset.url(with: imageOptions) else { return }

        self.af.setImage(
            withURL: url,
            placeholderImage: nil,
            imageTransition: .crossDissolve(0.5),
            runImageTransitionIfCached: true
        )
    }
}

private extension Asset {
    var imageSize: CGSize? {
        guard let info = file?.details?.imageInfo else { return nil }

        return CGSize(width: info.width, height: info.height)
    }
}
