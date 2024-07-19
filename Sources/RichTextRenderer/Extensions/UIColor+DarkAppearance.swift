// RichTextRenderer

import UIKit

public extension UIColor {
    /// Returns `UIColor.systemBackground` color or fallbacks to white.
    static var rtrSystemBackground: UIColor = {
        if #available(iOS 13.0, *) {
            return .systemBackground
        } else {
            return .white
        }
    }()

    /// Returns `UIColor.label` color or fallbacks to black.
    static var rtrLabel: UIColor = {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .black
        }
    }()
}
