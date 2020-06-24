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

    /// The characters that are to be used for unordered lists, by level. You can change this variable to use your own list item indicators.
    public static var unorderedListChars = ["•", "◦", "▪︎", "▫︎"]

    /// A boolean value which is true if the current list item being rendered is the first in the list.
    public var isFirstListItemChild: Bool

    /// A function returning the relevant unordered list item indicating character based on the current state.
    public func unorderedListItemBullet() -> String {
        return ListContext.unorderedListChars[max(0, level - 1) % ListContext.unorderedListChars.count]
    }

    /// Returns the relevant ordered list item indicator for the passed-in index. Uses the current state to determine the correct type of index character.
    public func orderedListItemIndicator(at index: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyz".map { String($0).uppercased() }

        var value: String
        switch level % 3 {
        case 0:
            value = toRoman(number: index + 1).lowercased()
        case 1:
            value = String(index + 1)
        case 2:
            value = String(characters[index % characters.count])
        default:
            fatalError()
        }
        value += "."
        return value
    }

    /// Returns the proper list item indicating character based on the current state of the list context
    public func listChar(at index: Int) -> String? {
        guard let parentType = parentType else { return nil }
        switch parentType {
        case .orderedList:
            return orderedListItemIndicator(at: index)
        case .unorderedList:
            return unorderedListItemBullet()
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

    /// A function which returns a roman numeral corresponding to the passed-in Int.
    // Inspired by: https://gist.github.com/kumo/a8e1cb1f4b7cff1548c7
    public func toRoman(number: Int) -> String {

        let romanValues = ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"]
        let arabicValues: [Int] = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]

        var romanValue = ""
        var startingValue = number

        for i in 0..<romanValues.count {
            let arabic = arabicValues[i]

            let divisor = startingValue / arabic

            guard divisor > 0 else { continue }
            for _ in 0..<divisor {
                romanValue += romanValues[i]
            }
            startingValue -= arabic * divisor
        }

        return romanValue
    }
}
