import Foundation
import Contentful
import UIKit

class SimpleTableViewCell: UIView {
    let isHeader: Bool
    let richTextViewController: RichTextViewController
    
    init(isHeader: Bool, nodes: [Node]) {
        self.isHeader = isHeader
        let configuration = DefaultRendererConfiguration()
        let renderer = RichTextDocumentRenderer(configuration: configuration)
        richTextViewController = RichTextViewController(renderer: renderer, isScrollEnabled: false)
        super.init(frame: .zero)
        layer.borderColor = UIColor(red: 177/255,
                                    green: 193/255,
                                    blue: 203/255,
                                    alpha: 1).cgColor
        layer.borderWidth = 0.5
        if isHeader {
            backgroundColor = UIColor(red: 232/255,
                                      green: 235/255,
                                      blue: 238/255,
                                      alpha: 1)
        }
        
        addSubview(richTextViewController.view)
        richTextViewController.view.translatesAutoresizingMaskIntoConstraints = false
        richTextViewController.view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        richTextViewController.view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        richTextViewController.view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        richTextViewController.view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        richTextViewController.richTextDocument = RichTextDocument(content: nodes)
        richTextViewController.updateTextViewBackground(color: .clear)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
