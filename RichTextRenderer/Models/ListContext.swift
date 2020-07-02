// RichTextRenderer

import Contentful

/// `ListContext` is a special type which is used by this library's renderers to apply the proper indentation to
/// lists and their items. It is also used to determine the proper character which should be used to indicate each list item
/// (i.e. a bullet, or ordered list index character).
public struct ListContext {

    /// The depth level of the current list. For instance, if the current list is nested within another list, the level would be set to 2.
    public var level: Int

    /// The current value in view points with which the current list item should be indented.
    public var indentationLevel: Int

    /// The parent type of the current list: only used to ensure nested lists are indented properly and using the proper indicating character.
    public var parentType: NodeType?

    /// The indext of the item in the list
    public var itemIndex: Int = 0

    /// A boolean value which is true if the current list item being rendered is the first in the list.
    public var isFirstListItemChild: Bool

    /// Returns the proper list item indicating character based on the current state of the list context
    public func listChar(at index: Int) -> String? {
        guard let parentType = parentType else { return nil }
        switch parentType {
        case .orderedList:
            let indicatorTypes = OrderedListIndicator.allCases
            let indicatorType = indicatorTypes[level % indicatorTypes.count]
            return indicatorType.indicator(forItemAt: index + 1) + "."
        case .unorderedList:
            let indicatorTypes = UnorderedListBullet.allCases
            let indicatorType = indicatorTypes[level % indicatorTypes.count]
            return indicatorType.rawValue
        default:
            return nil
        }
    }

    internal mutating func incrementIndentLevel(incrementNestingLevel: Bool) {
        itemIndex = 0
        indentationLevel += 1
        if incrementNestingLevel {
            level += 1
        } else {
            level = 1
        }
    }
}
