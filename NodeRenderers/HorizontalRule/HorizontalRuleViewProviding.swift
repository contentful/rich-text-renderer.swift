// ContentfulRichTextRenderer

/// Provides view representing horizontal line for a `HorizontalRule` node.
public protocol HorizontalRuleViewProviding {
    /// View representing horizontal line.
    func horizontalRule(context: [CodingUserInfoKey: Any]) -> View
}
