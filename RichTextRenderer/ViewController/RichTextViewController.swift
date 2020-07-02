// RichTextRenderer

import UIKit
import Contentful

/**
 View controller that renders `Contentful.RichTextDocument` to internal `UITextView`.

 It uses `NSLayoutManager` subclass, and a custom `NSTextContainer` subclass to render `UIView` instances inline
 in text.
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
    private let layoutManager = RichTextLayoutManager()

    /// Document to be rendered.
    public var richTextDocument: RichTextDocument? {
        didSet { renderDocumentIfNeeded() }
    }

    /// The custom `NSTextContainer` which manages the areas text can be rendered to.
    public var textContainer: RichTextContainer!

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

        layoutManager.textContainerInset = renderer.configuration.contentInset
        layoutManager.blockQuoteWidth = renderer.configuration.blockQuote.rectangleWidth
        layoutManager.blockQuoteColor = renderer.configuration.blockQuote.rectangleColor

        textStorage.addLayoutManager(layoutManager)

        textContainer = RichTextContainer(
            size: view.bounds.size,
            blockQuoteConfiguration: renderer.configuration.blockQuote
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
        textView.textContainerInset = renderer.configuration.contentInset
        textView.backgroundColor = UIColor.rtrSystemBackground

        view.addSubview(textView)

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
        exclusionPathsStorage = [:]
        textView.textContainer.exclusionPaths = []

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

        let output = self.renderer.render(document: document)

        DispatchQueue.main.async {
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
        guard let textView = self.textView, layoutFinishedFlag == true else { return }

        let layoutManager = textView.layoutManager

        layoutEmbeddedResourceViews(layoutManager: layoutManager)
        layoutHorizontalRules(layoutManager: layoutManager)
    }

    private func layoutEmbeddedResourceViews(layoutManager: NSLayoutManager) {
        let containerRect = self.view.frame
        let contentInset = renderer.configuration.contentInset

        // For each attached subview, find its associated attachment and position it according to its text layout
        let attachments = textView.textStorage.findAttachments(forAttribute: .embed)
        for attachment in attachments {
            guard let attachmentCastedView = attachment.view as? ResourceLinkBlockViewRepresentable else {
                attachment.view.isHidden = true
                continue
            }

            let glyphRange = layoutManager.glyphRange(
                forCharacterRange: NSRange(location: attachment.range.location, length: 1),
                actualCharacterRange: nil
            )

            let glyphIndex = glyphRange.location
            guard glyphIndex != NSNotFound && glyphRange.length == 1 else {
                attachment.view.isHidden = true
                continue
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

            let scaleFactor = newWidth / attachment.view.frame.width
            let newHeight = scaleFactor * attachment.view.frame.height

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

            let exclusionKey = String(attachment.range.hashValue) + "-embed"
            addExclusionPath(for: boundingRect, key: exclusionKey)

            if attachment.view.superview == nil {
                attachment.view.frame = attachmentRect
                textView.addSubview(attachment.view)
            }
        }
    }

    private func layoutHorizontalRules(layoutManager: NSLayoutManager) {
        let containerRect = self.view.frame
        let contentInset = renderer.configuration.contentInset

        let attachmentRanges = textView.textStorage.findAttachments(forAttribute: .horizontalRule)
        for attachment in attachmentRanges {
            let glyphRange = layoutManager.glyphRange(
                forCharacterRange: NSRange(location: attachment.range.location, length: 1),
                actualCharacterRange: nil
            )

            let glyphIndex = glyphRange.location
            guard glyphIndex != NSNotFound && glyphRange.length == 1 else {
                attachment.view.isHidden = true
                continue
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
                height: attachment.view.frame.height
            )

            let exclusionKey = String(attachment.range.hashValue) + "-horizontalRule"
            addExclusionPath(for: boundingRect, key: exclusionKey)

            if attachment.view.superview == nil {
                attachment.view.frame = attachmentRect
                textView.addSubview(attachment.view)
            }
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
