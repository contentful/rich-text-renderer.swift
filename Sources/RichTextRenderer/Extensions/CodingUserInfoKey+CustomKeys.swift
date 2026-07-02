// RichTextRenderer
import Foundation

public extension CodingUserInfoKey {
    /// Custom key used by the `context` dictionary of `NodeRenderer` methods to store `RenderingConfiguration`.
    static let rendererConfiguration = CodingUserInfoKey(rawValue: "rendererConfigurationKey")!

    /// Custom key used by the `context` dictionary of `NodeRenderer` methods to store `ListContext`.
    static let listContext = CodingUserInfoKey(rawValue: "listItemContextKey")!

    /// Custom key used by the `context` dictionary of `NodeRenderer` methods to store the parent `UIViewController`
    /// for proper UIKit view controller containment when embedding child view controllers.
    static let parentViewController = CodingUserInfoKey(rawValue: "parentViewControllerKey")!
}
