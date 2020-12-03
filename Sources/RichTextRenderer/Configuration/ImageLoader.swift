//  ImageLoader.swift

import UIKit

public protocol ImageLoader {
    func loadImage(with url: URL, into imageView: UIImageView)
}

public struct URLSessionImageLoader: ImageLoader {
    public let session: URLSession
    public let transitionOptions: UIImageView.AnimationOptions
    public let transitionDuration: TimeInterval

    public init(
        session: URLSession = .shared,
        transitionOptions: UIImageView.AnimationOptions = .transitionCrossDissolve,
        transitionDuration: TimeInterval = 0.5
    ) {
        self.session = session
        self.transitionOptions = transitionOptions
        self.transitionDuration = transitionDuration
    }

    public func loadImage(with url: URL, into imageView: UIImageView) {
        imageView.image = nil
        let task = session.dataTask(with: url) { [weak imageView] data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    if let imageView = imageView {
                        UIView.transition(
                            with: imageView,
                            duration: transitionDuration,
                            options: transitionOptions,
                            animations: {
                                imageView.image = image
                            },
                            completion: nil
                        )
                    }
                }
            }
        }

        task.resume()
    }
}
