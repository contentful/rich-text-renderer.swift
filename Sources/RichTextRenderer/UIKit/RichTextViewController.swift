//
//  RichTextViewController.swift
//  ContentfulRichTextRenderer
//
//  Created by JP Wright on 29/10/18.
//  Copyright © 2018 Contentful GmbH. All rights reserved.
//

import UIKit
import Contentful

/// A custom `UIViewController` subclass which will render a `Contentful.RichTextDocument` to a `UITextView`.
/// This class uses a custom `NSLayoutManager` subclass, and a custom `NSTextContainer` subclass to render `UIView` instances
/// inline in text. If you want to copy-paste this class to manipulate and customize your rendering further, read:
/// See: <https://developer.apple.com/documentation/appkit/textkit>
open class RichTextViewController: UIViewController, NSLayoutManagerDelegate {

    /// The `RichTextDocument` to render. This view controller can be initialzed with or without this variable;
    /// setting this variable will render the text to the text view.
    public var richText: RichTextDocument? {
        didSet {
            guard let richText = richText else { return }
            let output = self.renderer.render(document: richText)
            DispatchQueue.main.async {
                self.textStorage.beginEditing()
                self.textStorage.setAttributedString(output)
                self.textStorage.endEditing()
            }
        }
    }

    /// The renderer which renderes the `RichTextDocument`.
    public var renderer: RichTextRenderer = DefaultRichTextRenderer()

    /// The text view which the `RichTextDocument` is rendered to. This text view is a subview on this
    /// view controller's view.
    public var textView: UITextView!  {
        didSet {
            textView.textContainerInset = self.textContainerInset
        }
    }

    /// The underlying text storage.
    public let textStorage = NSTextStorage()

    /// The custom `NSLayoutManager` which lays out the text within the text container and text view.
    public let layoutManager = RichTextLayoutManager()

    /// The custom `NSTextContainer` which manages the areas text can be rendered to.
    public var textContainer: RichTextContainer!

    /// The insets from the text view to the text container.
    public var textContainerInset: UIEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0) {
        didSet {
            layoutManager.textContainerInset = textContainerInset
            textView.textContainerInset = textContainerInset
        }
    }

    /// Initializer
    ///
    /// - Parameters:
    ///   - richText: The `RichTextDocument` document to be rendered.
    ///   - renderer: The renderer to use which renders the `RichTextDocument`.
    ///   - nibName: The nib name, or nil, passed to the super initializer init(nibName:bundle)
    ///   - bundle: The bundle, or nil, passed to the super initializer init(nibName:bundle)
    public init(richText: RichTextDocument?, renderer: RichTextRenderer?, nibName: String?, bundle: Bundle?) {
        self.richText = richText
        self.renderer = renderer ?? DefaultRichTextRenderer()
        super.init(nibName: nibName, bundle: bundle)
        layoutManager.textContainerInset = self.textContainerInset
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if #available(iOS 11.0, *) {
            textView.frame = view.bounds.insetBy(dx: view.safeAreaInsets.left,
                                                 dy: view.safeAreaInsets.top)
            textView.center = view.center
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func rotated() {
        exclusionPaths = [:]
        textView.textContainer.exclusionPaths = []

        layoutManager.invalidateLayout(forCharacterRange: NSRange(location: 0, length: textStorage.length), actualCharacterRange: nil)

    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(RichTextViewController.rotated),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)

        layoutManager.blockQuoteWidth = renderer.config.blockQuote.rectangleWidth
        layoutManager.blockQuoteColor = renderer.config.blockQuote.rectangleColor

        textStorage.addLayoutManager(layoutManager)

        textContainer = RichTextContainer(size: view.bounds.size)
        textContainer.blockQuoteTextInset = renderer.config.blockQuote.textInset
        textContainer.blockQuoteWidth = renderer.config.blockQuote.rectangleWidth


        textContainer.widthTracksTextView = true
        textContainer.heightTracksTextView = true
        textContainer.lineBreakMode = .byWordWrapping

        layoutManager.addTextContainer(textContainer)
        layoutManager.delegate = self
        textView = UITextView(frame: view.bounds, textContainer: textContainer)

        view.addSubview(textView)
        textView.isScrollEnabled = true
        textView.contentSize.height = .greatestFiniteMagnitude
        textView.isEditable = false

        textContainer.size.height = .greatestFiniteMagnitude
    }

    public var exclusionPaths: [String: UIBezierPath] = [:]

    // Inspired by: https://github.com/vlas-voloshin/SubviewAttachingTextView/blob/master/SubviewAttachingTextView/SubviewAttachingTextViewBehavior.swift
    public func layoutManager(_ layoutManager: NSLayoutManager,
                              didCompleteLayoutFor textContainer: NSTextContainer?,
                              atEnd layoutFinishedFlag: Bool) {

        guard let textView = self.textView, layoutFinishedFlag == true else { return }

        let layoutManager = textView.layoutManager

        layoutEmbeddedResourceViews(layoutManager: layoutManager)
        layoutHorizontalRules(layoutManager: layoutManager)
    }

    private func boundingRectAndLineFragmentRect(forAttachmentCharacterAt characterIndex: Int,
                                                 attachmentView: View,
                                                 layoutManager: NSLayoutManager) -> (CGRect, CGRect)? {
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

    private func layoutEmbeddedResourceViews(layoutManager: NSLayoutManager) {
        // For each attached subview, find its associated attachment and position it according to its text layout
        let attachmentRanges = textView.textStorage.attachmentRanges(forAttribute: .embed) as! [(ResourceBlockView, NSRange)]
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
            adaptedRect.size.width = textViewSize.width - adaptedRect.origin.x - renderer.config.embedMargin - textView.textContainerInset.right - textView.textContainerInset.left
            view.layout(with: adaptedRect.width)

            // Make the exclusion rect take up the entire width so that text doesn't wrap where it shouldn't
            adaptedRect.size = view.frame.size

            var exclusionRect = adaptedRect

            if !view.surroundingTextShouldWrap {
                exclusionRect.size.width = textViewSize.width - exclusionRect.origin.x
            }

            exclusionRect = textView.convertRectFromTextContainer(exclusionRect)
            let convertedRect = textView.convertRectFromTextContainer(adaptedRect)

            if exclusionPaths[String(range.hashValue)] == nil {
                let exclusionPath = UIBezierPath(rect: exclusionRect)
                exclusionPaths[String(range.hashValue)] = exclusionPath
                textView.textContainer.exclusionPaths.append(exclusionPath)

                // If we have an embedded resource that extends below a list item indicator, we need to exclude it.
                if lineFragmentRect.height < convertedRect.height && !view.surroundingTextShouldWrap {
                    let additionalExclusionRect = CGRect(x: 0.0,
                                                         y: lineFragmentRect.origin.y + lineFragmentRect.height,
                                                         width: textViewSize.width,
                                                         height: exclusionRect.height - lineFragmentRect.height + renderer.config.embedMargin)
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

            adaptedRect.size.width = textViewSize.width - adaptedRect.origin.x - renderer.config.embedMargin - textView.textContainerInset.right - textView.textContainerInset.left
            view.frame.size.width = adaptedRect.width
            // Make the exclusion rect take up the entire width so that text doesn't wrap where it shouldn't
            adaptedRect.size = view.frame.size

            var exclusionRect = adaptedRect

            // Make exclusion rect span width of text view.
            exclusionRect.size.width = textViewSize.width - exclusionRect.origin.x

            exclusionRect = textView.convertRectFromTextContainer(exclusionRect)
            let convertedRect = textView.convertRectFromTextContainer(adaptedRect)

            if exclusionPaths[String(range.hashValue)] == nil {
                let exclusionPath = UIBezierPath(rect: exclusionRect)
                exclusionPaths[String(range.hashValue)] = exclusionPath
                textView.textContainer.exclusionPaths.append(exclusionPath)
                
                view.frame = convertedRect
                if view.superview == nil {
                    textView.addSubview(view)
                }
            }
        }
    }
}


/// A custom `NSLayoutManager` subclass which has special handling for rendering `Contentful.BlockQuote` nodes
/// with custom drawing.
public class RichTextLayoutManager: NSLayoutManager {

    var blockQuoteWidth: CGFloat!

    var blockQuoteColor: UIColor!

    var textContainerInset: UIEdgeInsets!

    public override init() {
        super.init()
        allowsNonContiguousLayout = true
    }

    public override var hasNonContiguousLayout: Bool {
        return true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // This draws the quote decoration block...need to make sure it works for both LtR and RtL languages.
    public override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        super.drawBackground(forGlyphRange: glyphsToShow, at: origin)

        // Draw the quote.
        let characterRange = self.characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
        textStorage?.enumerateAttributes(in: characterRange, options: []) { (attrs, range, _) in
            guard attrs[.block] != nil else { return }
            let context = UIGraphicsGetCurrentContext()
            context?.setLineWidth(0)

            self.blockQuoteColor.setFill()
            context?.saveGState()

            let textContainer = textContainers.first!
            let theseGlyphys = self.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
            var frame = boundingRect(forGlyphRange: theseGlyphys, in: textContainer)

            frame.size.width = blockQuoteWidth
            frame.origin.x = textContainerInset.left + textContainers.first!.lineFragmentPadding
            frame.origin.y += textContainers.first!.lineFragmentPadding
            frame.size.height += textContainers.first!.lineFragmentPadding * 2
            context?.saveGState()
            context?.fill(frame)
            context?.stroke(frame)
            context?.restoreGState()
        }
    }
}


/// The custom `NSTextContainer` which has handling for rendering `Contentful.BlockQuote` nodes
/// with a custom area.
public class RichTextContainer: NSTextContainer {

    var blockQuoteTextInset: CGFloat!

    var blockQuoteWidth: CGFloat!

    public override func lineFragmentRect(forProposedRect proposedRect: CGRect,
                                          at characterIndex: Int,
                                          writingDirection baseWritingDirection: NSWritingDirection,
                                          remaining remainingRect: UnsafeMutablePointer<CGRect>?) -> CGRect {
        let output = super.lineFragmentRect(forProposedRect: proposedRect,
                                            at: characterIndex,
                                            writingDirection: baseWritingDirection,
                                            remaining: remainingRect)

        let length = layoutManager!.textStorage!.length
        guard characterIndex < length else { return output }

        if layoutManager?.textStorage?.attribute(.block, at: characterIndex, effectiveRange: nil) != nil {
            return output.insetBy(dx: blockQuoteTextInset, dy: 0.0)
        }
        return output
    }
}
