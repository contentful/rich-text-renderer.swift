// RichTextRenderer
import Foundation

extension Dictionary where Key == CodingUserInfoKey {
    var rendererConfiguration: RendererConfiguration {
        return self[.rendererConfiguration] as! RendererConfiguration
    }
}
