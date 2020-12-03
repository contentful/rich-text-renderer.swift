//  AlamofireImageLoader.swift

import AlamofireImage
import ContentfulRichTextRenderer

struct AlamofireImageLoader: ImageLoader {
    var placeholderImage: UIImage? = nil
    var transition: UIImageView.ImageTransition = .crossDissolve(0.5)
    var runImageTransitionIfCached: Bool = true

    func loadImage(with url: URL, into imageView: UIImageView) {
        imageView.af.setImage(
            withURL: url,
            placeholderImage: placeholderImage,
            imageTransition: transition,
            runImageTransitionIfCached: runImageTransitionIfCached
        )
    }
}
