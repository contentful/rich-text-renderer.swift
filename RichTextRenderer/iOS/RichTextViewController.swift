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
    private let renderer: RichTextRenderer

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

    /// The insets from the text view to the text container.
    public var textContainerInset: UIEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0) {
        didSet {
            layoutManager.textContainerInset = textContainerInset
            textView.textContainerInset = textContainerInset
        }
    }

    public init(
        renderer: RichTextRenderer,
        richTextDocument: RichTextDocument? = nil
    ) {
        self.richTextDocument = richTextDocument
        self.renderer = renderer
        super.init(nibName: nil, bundle: nil)

        layoutManager.textContainerInset = self.textContainerInset
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        adjustTextViewOnDidLayoutSubviews()
    }

    deinit {
        stopObservingNotifications()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        observeOrientationDidChangeNotification()

        layoutManager.blockQuoteWidth = renderer.configuration.blockQuote.rectangleWidth
        layoutManager.blockQuoteColor = renderer.configuration.blockQuote.rectangleColor

        textStorage.addLayoutManager(layoutManager)

        textContainer = RichTextContainer(size: view.bounds.size)
        textContainer.blockQuoteTextInset = renderer.configuration.blockQuote.textInset
        textContainer.blockQuoteWidth = renderer.configuration.blockQuote.rectangleWidth

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
        textView.textContainerInset = self.textContainerInset
        view.addSubview(textView)

        textView.isScrollEnabled = true
        textView.contentSize.height = .greatestFiniteMagnitude
        textView.isEditable = false
    }

    private func adjustTextViewOnDidLayoutSubviews() {
        textView.frame = view.bounds.insetBy(
            dx: view.safeAreaInsets.left,
            dy: view.safeAreaInsets.top
        )

        textView.center = view.center
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
            forCharacterRange: NSRange(location: 0, length: textStorage.length),
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
        // For each attached subview, find its associated attachment and position it according to its text layout
        let attachmentRanges = textView.textStorage.attachmentRanges(forAttribute: .embed) as! [(ResourceLinkBlockViewRepresentable, NSRange)]
        for (view, range) in attachmentRanges {
            guard let (attachmentRect, lineFragmentRect) = boundingRectAndLineFragmentRect(forAttachmentCharacterAt: range.location,
                                                                                           attachmentView: view,
                                                                                           layoutManager: layoutManager) else {
                // If we can't determine the rectangle for the attachment: just hide it.
                view.isHidden = true
                continue
            }

            // Make the view's frame the correct width.
            var adaptedRect = attachmentRect
            let textViewSize = self.view.frame.size
            adaptedRect.size.width = textViewSize.width - adaptedRect.origin.x - renderer.configuration.embedMargin - textView.textContainerInset.right - textView.textContainerInset.left
            view.layout(with: adaptedRect.width)

            // Make the exclusion rect take up the entire width so that text doesn't wrap where it shouldn't
            adaptedRect.size = view.frame.size

            var exclusionRect = adaptedRect

            if !view.surroundingTextShouldWrap {
                exclusionRect.size.width = textViewSize.width - exclusionRect.origin.x
            }

            exclusionRect = textView.convertRectFromTextContainer(exclusionRect)
            let convertedRect = textView.convertRectFromTextContainer(adaptedRect)

            if exclusionPathsStorage[String(range.hashValue)] == nil {
                let exclusionPath = UIBezierPath(rect: exclusionRect)
                exclusionPathsStorage[String(range.hashValue)] = exclusionPath
                textView.textContainer.exclusionPaths.append(exclusionPath)

                // If we have an embedded resource that extends below a list item indicator, we need to exclude it.
                if lineFragmentRect.height < convertedRect.height && !view.surroundingTextShouldWrap {
                    let additionalExclusionRect = CGRect(x: 0.0,
                                                         y: lineFragmentRect.origin.y + lineFragmentRect.height,
                                                         width: textViewSize.width,
                                                         height: exclusionRect.height - lineFragmentRect.height + renderer.configuration.embedMargin)
                    textView.textContainer.exclusionPaths.append(UIBezierPath(rect: additionalExclusionRect))
                }

                view.frame = convertedRect
                if view.superview == nil {
                    textView.addSubview(view)
                }
            }
        }
    }

    private func layoutHorizontalRules(layoutManager: NSLayoutManager) {
        let attachmentRanges = textView.textStorage.attachmentRanges(forAttribute: .horizontalRule)

        for (view, range) in attachmentRanges {
            guard let (attachmentRect, _) = boundingRectAndLineFragmentRect(forAttachmentCharacterAt: range.location,
                                                                            attachmentView: view,
                                                                            layoutManager: layoutManager) else {
                // If we can't determine the rectangle for the attachment: just hide it.
                view.isHidden = true
                continue
            }
            // Make the view's frame the correct width.
            var adaptedRect = attachmentRect
            let textViewSize = self.view.frame.size

            adaptedRect.size.width = textViewSize.width - adaptedRect.origin.x - renderer.configuration.embedMargin - textView.textContainerInset.right - textView.textContainerInset.left
            view.frame.size.width = adaptedRect.width
            // Make the exclusion rect take up the entire width so that text doesn't wrap where it shouldn't
            adaptedRect.size = view.frame.size

            var exclusionRect = adaptedRect

            // Make exclusion rect span width of text view.
            exclusionRect.size.width = textViewSize.width - exclusionRect.origin.x

            exclusionRect = textView.convertRectFromTextContainer(exclusionRect)
            let convertedRect = textView.convertRectFromTextContainer(adaptedRect)

            if exclusionPathsStorage[String(range.hashValue)] == nil {
                let exclusionPath = UIBezierPath(rect: exclusionRect)
                exclusionPathsStorage[String(range.hashValue)] = exclusionPath
                textView.textContainer.exclusionPaths.append(exclusionPath)

                view.frame = convertedRect
                if view.superview == nil {
                    textView.addSubview(view)
                }
            }
        }
    }

    private func boundingRectAndLineFragmentRect(
        forAttachmentCharacterAt characterIndex: Int,
        attachmentView: View,
        layoutManager: NSLayoutManager
    ) -> (CGRect, CGRect)? {
        let glyphRange = layoutManager.glyphRange(forCharacterRange: NSRange(location: characterIndex, length: 1), actualCharacterRange: nil)
        let glyphIndex = glyphRange.location
        guard glyphIndex != NSNotFound && glyphRange.length == 1 else {
            return nil
        }

        let lineFragmentRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: nil)
        let glyphLocation = layoutManager.location(forGlyphAt: glyphIndex)

        let textViewSize = self.view.frame.size

        let newWidth = textViewSize.width - lineFragmentRect.minX
        let scaleFactor = newWidth / attachmentView.frame.width
        let newHeight = scaleFactor * attachmentView.frame.height

        let boundingRect = CGRect(x: lineFragmentRect.minX + glyphLocation.x,
                                  y: lineFragmentRect.minY,
                                  width: newWidth,
                                  height: newHeight)
        return (boundingRect, lineFragmentRect)
    }
}
