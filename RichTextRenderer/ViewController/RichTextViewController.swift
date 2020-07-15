// RichTextRenderer

import UIKit
import Contentful

/**
 View controller that renders `Contentful.RichTextDocument`.

 The content of the document is rendered to internal text view.
*/
open class RichTextViewController: UIViewController, NSLayoutManagerDelegate {

    /// Renderer of the `Contentful.RichTextDocument`.
    private let renderer: RichTextDocumentRenderer

    /// The `renderer` renders `Contentful.RichTextDocument` into this view.
    private var textView: UITextView!

    /// The underlying text storage.
    private let textStorage = NSTextStorage()

    /// Storage for exclusion paths, regions where a text is not rendered in the text container.
    private var exclusionPathsStorage: [String: UIBezierPath] = [:]

    /// The custom `NSLayoutManager` which lays out the text within the text container and text view.
    private let layoutManager = DefaultLayoutManager()

    /// Document to be rendered.
    public var richTextDocument: RichTextDocument? {
        didSet { renderDocumentIfNeeded() }
    }

    /// The custom `NSTextContainer` which manages the areas text can be rendered to.
    private var textContainer: ConcreteTextContainer!

    public init(
        renderer: RichTextDocumentRenderer,
        richTextDocument: RichTextDocument? = nil
    ) {
        self.richTextDocument = richTextDocument
        self.renderer = renderer
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        stopObservingNotifications()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        observeOrientationDidChangeNotification()

        layoutManager.blockQuoteDecorationRenderer = BlockQuoteDecorationRenderer(
            blockQuoteConfiguration: renderer.configuration.blockQuote,
            textContainerInsets: renderer.configuration.contentInsets
        )

        textStorage.addLayoutManager(layoutManager)

        textContainer = ConcreteTextContainer(size: view.bounds.size)
        textContainer.add(provider: BlockLineFragmentProvider(
            blockQuoteConfiguration: renderer.configuration.blockQuote)
        )

        textContainer.widthTracksTextView = true
        textContainer.heightTracksTextView = true
        textContainer.lineBreakMode = .byWordWrapping

        layoutManager.addTextContainer(textContainer)
        layoutManager.delegate = self

        setupTextView()

        textContainer.size.height = .greatestFiniteMagnitude
    }

    private func setupTextView() {
        textView = UITextView(frame: view.bounds, textContainer: textContainer)
        textView.textContainerInset = renderer.configuration.contentInsets
        textView.backgroundColor = UIColor.rtrSystemBackground

        view.addSubview(textView)

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true

        textView.isScrollEnabled = true
        textView.contentSize.height = .greatestFiniteMagnitude
        textView.isEditable = false
    }

    private func observeOrientationDidChangeNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOrientationDidChangeNotification),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    @objc private func handleOrientationDidChangeNotification() {
        invalidateLayout()
    }

    private func invalidateLayout() {
        exclusionPathsStorage.removeAll()
        textView.textContainer.exclusionPaths.removeAll()

        layoutManager.invalidateLayout(
            forCharacterRange: textStorage.fullRange,
            actualCharacterRange: nil
        )
    }

    private func stopObservingNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    private func renderDocumentIfNeeded() {
        guard let document = richTextDocument else { return }

        DispatchQueue.main.async {
            let output = self.renderer.render(document: document)
            self.textStorage.beginEditing()
            self.textStorage.setAttributedString(output)
            self.textStorage.endEditing()
        }
    }


    // MARK: - NSLayoutManagerDelegate

    // Inspired by: https://github.com/vlas-voloshin/SubviewAttachingTextView/blob/master/SubviewAttachingTextView/SubviewAttachingTextViewBehavior.swift
    public func layoutManager(
        _ layoutManager: NSLayoutManager,
        didCompleteLayoutFor textContainer: NSTextContainer?,
        atEnd layoutFinishedFlag: Bool
    ) {
        guard layoutFinishedFlag == true else { return }

        layoutCustomElements()
    }

    private func layoutCustomElements() {
        textView.textStorage.enumerateAttributes(
            in: textView.textStorage.fullRange,
            options: []
        ) { attributes, range, _ in
            if attributes.keys.contains(.embed) {
                layoutEmbedElement(attributes: attributes, range: range)
            } else if attributes.keys.contains(.horizontalRule) {
                layoutHorizontalRuleElement(attributes: attributes, range: range)
            }
        }
    }

    private func layoutEmbedElement(attributes: [NSAttributedString.Key: Any], range: NSRange) {
        let containerRect = self.view.frame
        let contentInset = renderer.configuration.contentInsets

        guard let attrView = attributes[.embed] as? UIView else {
            return
        }

        guard let attachmentCastedView = attrView as? ResourceLinkBlockViewRepresentable else {
            attrView.isHidden = true
            return
        }

        let glyphRange = layoutManager.glyphRange(
            forCharacterRange: NSRange(location: range.location, length: 1),
            actualCharacterRange: nil
        )

        let glyphIndex = glyphRange.location
        guard glyphIndex != NSNotFound && glyphRange.length == 1 else {
            attrView.isHidden = true
            return
        }

        let lineFragmentRect = layoutManager.lineFragmentRect(
            forGlyphAt: glyphIndex,
            effectiveRange: nil
        )

        let glyphLocation = layoutManager.location(forGlyphAt: glyphIndex)

        let newWidth = containerRect.width
            - lineFragmentRect.minX
            - glyphLocation.x
            - contentInset.left
            - contentInset.right

        let scaleFactor = newWidth / attrView.frame.width
        let newHeight = scaleFactor * attrView.frame.height

        // Rect specifying an area where text should not be rendered.
        let boundingRect = CGRect(
            x: lineFragmentRect.minX,
            y: lineFragmentRect.minY,
            width: containerRect.width,
            height: newHeight
        )

        // Rect specifying an area where the attachment is rendered. This can differ from the `boundingRect`.
        let attachmentRect = CGRect(
            x: lineFragmentRect.minX + glyphLocation.x + contentInset.left,
            y: lineFragmentRect.minY + contentInset.top,
            width: newWidth,
            height: newHeight
        )

        attachmentCastedView.layout(with: attachmentRect.width)

        let exclusionKey = String(range.hashValue) + "-embed"
        addExclusionPath(for: boundingRect, key: exclusionKey)

        if attrView.superview == nil {
            attrView.frame = attachmentRect
            textView.addSubview(attrView)
        }
    }

    private func layoutHorizontalRuleElement(attributes: [NSAttributedString.Key: Any], range: NSRange) {
        let containerRect = self.view.frame
        let contentInset = renderer.configuration.contentInsets

        guard let attrView = attributes[.horizontalRule] as? UIView else {
            return
        }

        let glyphRange = layoutManager.glyphRange(
            forCharacterRange: NSRange(location: range.location, length: 1),
            actualCharacterRange: nil
        )

        let glyphIndex = glyphRange.location
        guard glyphIndex != NSNotFound && glyphRange.length == 1 else {
            attrView.isHidden = true
            return
        }

        let lineFragmentRect = layoutManager.lineFragmentRect(
            forGlyphAt: glyphIndex,
            effectiveRange: nil
        )

        let glyphLocation = layoutManager.location(forGlyphAt: glyphIndex)

        let newWidth = containerRect.width
            - lineFragmentRect.minX
            - contentInset.left
            - contentInset.right

        let boundingRect = CGRect(
            x: lineFragmentRect.minX,
            y: lineFragmentRect.minY,
            width: containerRect.width,
            height: 0
        )

        let attachmentRect = CGRect(
            x: lineFragmentRect.minX + glyphLocation.x + contentInset.left,
            y: lineFragmentRect.minY + contentInset.top,
            width: newWidth,
            height: attrView.frame.height
        )

        let exclusionKey = String(range.hashValue) + "-horizontalRule"
        addExclusionPath(for: boundingRect, key: exclusionKey)

        if attrView.superview == nil {
            attrView.frame = attachmentRect
            textView.addSubview(attrView)
        }
    }

    /**
     Adds exclusion path for a passed in rect.
     - Parameters:
        - rect: Rect for which exclusion path should be set.
        - key: String uniquely representing the exlusioned rect.
     */
    private func addExclusionPath(for rect: CGRect, key: String) {
        guard exclusionPathsStorage[key] == nil else { return }

        let exclusionPath = UIBezierPath(rect: rect)
        exclusionPathsStorage[key] = exclusionPath
        textView.textContainer.exclusionPaths.append(exclusionPath)
    }
}
