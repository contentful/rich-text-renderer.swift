// RichTextRenderer

import UIKit

/// Represents color in light and dark appearance.
public struct Color {
    enum Appearance {
        case light
        case dark
    }

    private let light: UIColor
    private let dark: UIColor

    /// Initialize with color for light and color for dark appearance.
    public init(light: UIColor, dark: UIColor) {
        self.light = light
        self.dark = dark
    }

    /// Initialize with color that is same for light and dark appearance.
    public init(color: UIColor) {
        self.init(light: color, dark: color)
    }
}
