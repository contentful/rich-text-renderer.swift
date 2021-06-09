// RichTextRenderer

import Contentful
import UIKit

/// Default `Asset` view representable for image kind of asset.
public class ResourceLinkBlockImageView: UIImageView, ResourceLinkBlockViewRepresentable {

    private var asset: Asset
    public var context: [CodingUserInfoKey: Any]

    public init(asset: Asset, context: [CodingUserInfoKey: Any] = [:]) {
        self.asset = asset
        self.context = context
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
        // Get the current width of the cell and see if it is wider than the screen.
        guard let imageSize = asset.imageSize else { return }

        // Use scale to get the pixel size of the image view.
        let scale = UIScreen.main.scale

        let viewWidthPixels = UIScreen.main.bounds.width * scale
        let percentageDifference = viewWidthPixels / imageSize.width

        let viewHeightInPoints = imageSize.height * percentageDifference / scale
        let viewHeightPixels = viewHeightInPoints * scale

        frame.size = CGSize(
            width: UIScreen.main.bounds.width,
            height: viewHeightInPoints
        )

        let imageOptions: [ImageOption] = [
            .formatAs(.jpg(withQuality: .asPercent(100))),
            .width(UInt(viewWidthPixels)),
            .height(UInt(viewHeightPixels)),
        ] + additionalOptions

        let url = try! asset.url(with: imageOptions)

        context.rendererConfiguration.imageLoader.loadImage(with: url, into: self)
    }
}

private extension Asset {
    var imageSize: CGSize? {
        guard let info = file?.details?.imageInfo else { return nil }

        return CGSize(width: info.width, height: info.height)
    }
}
