// RichTextRenderer

import Contentful

/// `ListContext` is a special type which is used by this library's renderers to apply the proper indentation to
/// lists and their items. It is also used to determine the proper character which should be used to indicate each list item
/// (i.e. a bullet, or ordered list index character).
public struct ListContext {
    public enum ListType {
        case ordered
        case unordered
    }

    /// Depth level of the list.
    public var level: Int

    /// The current value in view points with which the current list item should be indented.
    public var indentationLevel: Int {
        return level
    }

    /// Type of the list.
    public var listType: ListType

    /// The indext of the item in the list
    public var itemIndex: Int = 0

    /// A boolean value which is true if the current list item being rendered is the first in the list.
    public var isFirstListItemChild: Bool

    public init(
        listType: ListType
    ) {
        self.level = 1
        self.listType = listType
        self.itemIndex = 0
        self.isFirstListItemChild = true
    }

    /// Returns the proper list item indicating character based on the current state of the list context
    public func listChar(at index: Int) -> String? {
        switch listType {
        case .ordered:
            let indicatorTypes: [OrderedListIndicator] = [
                .number,
                .alphabet(true),
                .romanNumber,
                .alphabet(false),
                .alphabet(false),
                .alphabet(false)
            ]

            let indicatorType = indicatorTypes[level - 1 % indicatorTypes.count]
            return indicatorType.indicator(forItemAt: index) + "."
        case .unordered:
            let indicatorTypes: [UnorderedListBullet] = [
                .fullCircle,
                .emptyCircle,
                .fullSquare,
                .fullSquare,
                .fullSquare
            ]

            let indicatorType = indicatorTypes[max(0, level - 1) % indicatorTypes.count]
            return indicatorType.rawValue
        }
    }
}
