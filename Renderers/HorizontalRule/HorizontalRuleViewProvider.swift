// ContentfulRichTextRenderer

import UIKit

/// Default implementation of the `HorizontalRuleViewProviding`.
public final class HorizontalRuleViewProvider: HorizontalRuleViewProviding {
    public func horizontalRule(context: [CodingUserInfoKey: Any]) -> View {
        let view = View(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height:  1.0))
        view.backgroundColor = .lightGray
        return view
    }
}
