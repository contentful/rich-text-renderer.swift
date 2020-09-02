// RichTextRenderer

/**
 Context for list renderer to keep track of the current indentation level of the list items and to properly
 render items on list.
*/
public struct ListContext {
    /// Depth level of the list.
    public var level: Int

    /// Type of the list.
    public var listType: ListType

    /// The indext of the item in the list
    public var itemIndex: Int = 0

    /// A boolean value which is true if the current list item being rendered is the first in the list.
    public var isFirstListItemChild: Bool

    public init(listType: ListType) {
        self.level = 1
        self.listType = listType
        self.itemIndex = 0
        self.isFirstListItemChild = true
    }
}
