# Architecture

`ContentfulRichTextRenderer` turns a `Contentful.RichTextDocument` — a tree of
typed nodes delivered by the Contentful Delivery API — into an
`NSAttributedString`, and then displays that string in a `UITextView` whose
TextKit stack has been customised so that native `UIView`s can be embedded in the
text flow and so that text can wrap around them.

Everything below lives under `Sources/RichTextRenderer/`.

## Two layers

The library separates *producing an attributed string* from *displaying it*. They
are usable independently.

### 1. Rendering layer — document tree to `NSAttributedString`

```
RichTextDocument (from Contentful SDK)
  └─ node ──▶ RenderableNodeProviding ──▶ RenderableNode (enum)
                                            └─ NodeRenderersProviding ──▶ concrete NodeRendering
                                                                            └─ [NSMutableAttributedString]
```

- `Renderer/RichTextDocumentRendering.swift` — the protocol a renderer conforms to.
- `Renderer/RichTextDocumentRenderer.swift` — the concrete `struct`. `render(document:)`
  maps `document.content` to `RenderableNodeProviding`, renders each child, and
  concatenates the results. It deliberately drops the last produced fragment to
  strip the trailing empty line under the document.
- `Extensions/Node+RenderableNodeProviding.swift` — conformances that map each
  Contentful SDK node type (`Paragraph`, `Heading`, `Table`, `ResourceLinkBlock`, …)
  onto a case of the `RenderableNode` enum in `Models/RenderableNode.swift`.
  This enum is the seam between the Contentful SDK's node types and this library's
  dispatch table.
- `Renderer/NodeRenderersProviding.swift` — a protocol with one mutable property per
  node type, plus a protocol extension holding the `switch` over `RenderableNode`
  that performs dispatch. `Renderer/Default/DefaultRenderersProvider.swift` is the
  default set. Because every property is `var`, a consumer swaps in a custom
  renderer by assignment (`renderersProvider.paragraph = MyParagraphRenderer()`),
  not by subclassing the renderer.
- `NodeRenderers/<NodeType>/…Renderer.swift` — one renderer per node type, each
  conforming to `NodeRendering` (`NodeRenderers/NodeRendering.swift`). A renderer
  returns `[NSMutableAttributedString]` and may optionally return a `UIView` — the
  protocol extension provides a `nil` default for `view(node:rootRenderer:context:)`,
  so only view-producing renderers override it.

Renderers receive `rootRenderer: RichTextDocumentRendering` so they can recurse into
their own children, and a `context: [CodingUserInfoKey: Any]` dictionary that carries
ambient state. The keys are defined in
`Extensions/CodingUserInfoKey+CustomKeys.swift`:

- `.rendererConfiguration` — the active `RendererConfiguration`
- `.listContext` — current list depth, list type, and item index (`Models/List/ListContext.swift`)
- `.parentViewController` — used for UIKit view-controller containment when a
  renderer embeds a child view controller

`RichTextDocumentRenderer.render(document:additionalContext:)` is the overload for
injecting extra context entries on top of the base context.

### 2. Presentation layer — attributed string to screen

`ViewController/RichTextViewController.swift` is an `open class UIViewController`
that consumers use standalone or subclass. It owns the whole TextKit stack
explicitly rather than relying on `UITextView`'s built-in one:

- `NSTextStorage` — plain, holds the rendered string.
- `DefaultLayoutManager` (`ViewController/LayoutManager/DefaultLayoutManager.swift`)
  — an `NSLayoutManager` subclass with `allowsNonContiguousLayout = true` that
  overrides `drawBackground(forGlyphRange:at:)`. It enumerates attributes over the
  glyph range and, when it finds the `.block` attribute, delegates to a
  `DecorationRendering` implementation. `BlockQuoteDecorationRenderer` is the one
  shipped implementation — this is how the blockquote bar is drawn.
- `ConcreteTextContainer` (`ViewController/TextContainer/ConcreteTextContainer.swift`)
  — an `NSTextContainer` subclass that overrides
  `lineFragmentRect(forProposedRect:at:writingDirection:remaining:)` and consults a
  list of `LineFragmentProviding` objects. `BlockLineFragmentProvider` uses this to
  indent lines inside blockquotes.
- Exclusion paths — the view controller keeps `exclusionPathsStorage:
  [String: UIBezierPath]` and `attachmentViews: [String: UIView]`, keyed by
  identifiers suffixed `-embed` and `-hr`. Embedded views are added as subviews of
  the text view and a matching exclusion path is installed so text flows around
  them.

Communication between the two layers happens through custom attributed-string keys
in `Extensions/NSAttributedStringKey+Contentful.swift`: `.block`, `.embed`, and
`.horizontalRule`. The rendering layer stamps these onto ranges; the presentation
layer reads them back to decide what to draw or lay out. This is the reason the
rendering layer can stay UIKit-view-agnostic while still driving view placement.

## Configuration and extension points

`Renderer/RendererConfiguration.swift` is the protocol; `Renderer/Default/DefaultRendererConfiguration.swift`
is the mutable struct with sane defaults that consumers are expected to instantiate
and tweak. Per-node configuration structs live in `Configuration/`
(`TextConfiguration`, `BlockQuoteConfiguration`, `TextListConfiguration`, each with a
`+Default` companion). Fonts and colours come from `StyleProviding`
(`Configuration/StyleProviding.swift`, default in `Renderer/Default/DefaultStyleProvider.swift`).

The three consumer-supplied plugin points, all reached through the configuration:

| Protocol | Purpose |
| --- | --- |
| `ResourceLinkBlockViewProviding` | return a `UIView` for an embedded entry or asset |
| `ResourceLinkInlineStringProviding` | return an `NSMutableAttributedString` for an inline entry |
| `HorizontalRuleViewProviding` | return the view used for `HorizontalRule` nodes |

`onHyperlinkPressed` and `onResourceHyperlinkPressed` closures on the configuration
handle tap callbacks.

## Tables

Table support is newer and is structured differently from the other node types:
`NodeRenderers/Table/Components/` holds the four renderers (`TableRenderer`,
`TableRowRenderer`, `TableCellRenderer`, `TableHeaderCellRenderer`), and
`NodeRenderers/Table/SimpleImplementation/` holds a concrete `SimpleTableView` /
`SimpleTableViewRow` / `SimpleTableViewCell` trio that those renderers use to build
an embedded view. Tables are therefore rendered as an embedded `UIView`, not as
attributed text.

## Dependencies

Declared in three places for three distribution channels (`Package.swift`,
`ContentfulRichTextRenderer.podspec`, `Cartfile`):

- `contentful.swift` — supplies `RichTextDocument` and all node types. This is the
  hard coupling; a breaking change in its node model is a breaking change here.
- `AlamofireImage` — used by `ResourceLinkBlockImageView` to download asset images.
  `Alamofire` comes in transitively.

`Package.resolved` currently pins Contentful 5.5.14, AlamofireImage 4.3.0, and
Alamofire 5.10.2.

The `RichTextRenderer` framework target in the Xcode project links the dynamic
Contentful, AlamofireImage and Alamofire frameworks that Carthage builds from
`Cartfile` / `Cartfile.resolved` (`carthage bootstrap --use-xcframeworks --platform iOS`),
so Carthage consumers get one copy of each; see
`docs/ADRs/2026-09-23-framework-target-links-carthage-dependencies.md`.

Resolved CocoaPods sources are still committed under `Pods/` for the example apps; see
`docs/ADRs/2026-08-25-commit-cocoapods-pods-directory.md`.

## Platform and toolchain

- iOS 13 minimum in `Package.swift`, the podspec, and the `Podfile` (and the example apps).
- Swift 5.2 (`.swift-version`, `swift-tools-version`, `spec.swift_version`).
- UIKit-only. There is no macOS, tvOS, or watchOS support, and no SwiftUI-native
  rendering path — the SwiftUI example wraps `RichTextViewController` in a
  `UIViewControllerRepresentable` (`Example-iOS-SwiftUI/.../RichTextHostView.swift`).
- `PrivacyInfo.xcprivacy` declares the required-reason APIs (file timestamp, user
  defaults, system boot time) and states no data collection and no tracking.

## What is not here

- No test target and no tests, in either the SPM package or the Xcode project.
- No dedicated build or release CI. The one committed workflow,
  `.github/workflows/codeql.yml`, scans workflow files only; CodeQL default setup
  (configured at the repo level for `actions`, `ruby`, `swift`) is what actually
  compiles the library on a PR.
- No changelog file and no release automation. Versions are bumped with
  `Scripts/set-version.sh` and released by hand with `Scripts/release.sh`
  (`0.4.1` … `0.4.10`); see `RELEASING.md`. CocoaPods is frozen at 0.4.10.
