// RichTextRenderer

struct ListItemIndicatorFactory {
    /// Creates proper string indicator representing a bullet point, number or character that is presented on list.
    func makeIndicator(
        forListType listType: ListType,
        atIndex index: Int,
        atLevel level: Int
    ) -> String {
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
