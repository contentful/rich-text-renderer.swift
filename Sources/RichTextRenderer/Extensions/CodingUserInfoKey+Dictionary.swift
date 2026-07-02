// RichTextRenderer
import Foundation
import UIKit

extension Dictionary where Key == CodingUserInfoKey {
    var rendererConfiguration: RendererConfiguration {
        return self[.rendererConfiguration] as! RendererConfiguration
    }

    var parentViewController: UIViewController? {
        return self[.parentViewController] as? UIViewController
    }
}
