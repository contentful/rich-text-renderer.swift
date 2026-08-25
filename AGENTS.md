# AGENTS.md

Guidance for coding agents working in `contentful/rich-text-renderer.swift`.

## What this repository is

`ContentfulRichTextRenderer` is an iOS-only Swift library that renders a
`Contentful.RichTextDocument` into an `NSAttributedString` with native `UIView`
instances embedded in the text flow. It is built on TextKit (`NSLayoutManager`,
`NSTextContainer`, `NSTextStorage`) and is consumed as a UIKit view controller.

- Product / module name: `ContentfulRichTextRenderer` (import as `RichTextRenderer`)
- Library sources: `Sources/RichTextRenderer/`
- Public entry points: `RichTextViewController` and `RichTextDocumentRenderer`
- Platform floor: iOS 13 (`Package.swift`, `ContentfulRichTextRenderer.podspec`)
- Swift version: 5.2 (`.swift-version`, `swift-tools-version:5.2`, `spec.swift_version`)
- Default branch: `master` (not `main`)
- Owner: `@contentful/team-developer-experience` (`.github/CODEOWNERS`), service tier 4
  (`catalog-info.yaml`)

## Repository facts you need before you edit anything

1. **There is no test suite.** `Sources/` contains no test target, `Package.swift`
   declares only the `RichTextRenderer` target, and
   `RichTextRenderer.xcodeproj/xcshareddata/xcschemes/RichTextRenderer.xcscheme`
   contains zero `TestableReference` entries. Do not claim a change is "verified by
   tests" — there are none to run. Verification here means building and exercising
   one of the example apps by hand.
2. **`Pods/` is committed to the repository.** This is deliberate; see
   `docs/ADRs/2026-08-25-commit-cocoapods-pods-directory.md`. Do not delete it, do
   not add it back to `.gitignore`, and if you run `pod install` be aware that the
   resulting churn under `Pods/` is a real diff that will show up in `git status`.
3. **Three distribution channels are maintained in parallel** and each has its own
   dependency declaration. If you change a dependency you must consider all three:
   - `Package.swift` — Swift Package Manager
   - `ContentfulRichTextRenderer.podspec` + `Podfile` — CocoaPods
   - `Cartfile` — Carthage
   They are not currently in lockstep (see "Known inconsistencies" below); do not
   silently "fix" them as a drive-by.
4. **CI does not build this library.** The only workflow is
   `.github/workflows/codeql.yml`, which runs CodeQL against
   `.github/workflows/**` only. A green PR does not mean the library compiles.
5. `catalog-info.yaml` still routes CI alerts to the `sdk-bots` Slack channel even
   though no build CI exists.

## Building

There is no `Makefile`, `Rakefile`, or `fastlane` directory. Use the toolchain
directly:

```sh
# Swift Package Manager resolve (iOS-only library; `swift build` on macOS will not
# work because the target imports UIKit)
swift package resolve

# Build the framework target via the shared Xcode scheme
xcodebuild -project RichTextRenderer.xcodeproj -scheme RichTextRenderer \
  -sdk iphonesimulator -configuration Debug build

# Example apps live in the workspace alongside the Pods project
open RichTextRenderer.xcworkspace
```

`RichTextRenderer.xcworkspace` references `Example-iOS-SwiftUI`, `Example-iOS`,
`RichTextRenderer.xcodeproj`, and `Pods/Pods.xcodeproj`.

The Ruby toolchain in `Gemfile` is `cocoapods`, `xcpretty`, `slather`, `jazzy`, and
`dotenv`. Install with `bundle install` if you need `pod`.

## Running the examples

Both example apps talk to a real Contentful space through
`Example-iOS*/Example-iOS*/Contentful/ContentfulService.swift`, so they need
credentials you may not have. Do not assume you can run them.

- `Example-iOS` — UIKit; `ViewController` subclasses `RichTextViewController`.
- `Example-iOS-SwiftUI` — wraps the UIKit controller in a
  `UIViewControllerRepresentable` (`RichTextHostView.swift`).

## Conventions to match

- Most files in `Sources/RichTextRenderer/` (60 of 70 `.swift` files) open with the
  comment `// RichTextRenderer`. Keep that header on files you add.
- 4-space indent, trailing-comma-free multi-line argument lists broken one argument
  per line — match the surrounding file rather than reformatting it.
- Public API is documented with `///` doc comments. New public symbols should be too.
- Directory layout mirrors concepts: `NodeRenderers/<NodeType>/`, `Configuration/`,
  `Models/`, `Extensions/`, `Renderer/`, `ViewController/`. Put new code in the
  directory that already owns that concept.
- Default implementations live in `*+Default.swift` or `Renderer/Default/`.
- Extensions on Foundation/UIKit types are named `Type+Behaviour.swift`.

## Releasing

Releases are manual and driven off the podspec version. There is no
semantic-release, no changelog file, and no publish workflow.

1. Bump `spec.version` in `ContentfulRichTextRenderer.podspec`.
2. Merge to `master`.
3. Tag the commit with the bare version number — existing tags are `0.4.1` … `0.4.10`,
   no `v` prefix.
4. Push the pod to trunk.

Version bump commits in history are plain `chore:` commits (for example `f5255b8
chore: update version`), so a `docs:` or `chore:` commit will not trigger any
automated release here.

## Known inconsistencies (do not treat as bugs to fix silently)

- `Podfile` declares `platform :ios, '11.0'` while `Package.swift` and the podspec
  declare iOS 13. The README's CocoaPods snippet also says `11.0`.
- `ContentfulRichTextRenderer.podspec` still points `spec.homepage` and
  `spec.source` at `contentful-labs/rich-text-renderer.swift`; the repository now
  lives at `contentful/rich-text-renderer.swift` and the README's Carthage snippet
  uses the `contentful/` path.
- `Cartfile` pins `contentful.swift ~> 5.5.7` while `Package.swift` uses
  `from: "5.2.0"` and the podspec uses `~> 5`.

If you fix one of these, say so explicitly in the PR description — each one is
user-visible in a different install path.

## Hard rules

- Never commit credentials, space IDs paired with access tokens, or `.env` files.
- Do not weaken `.gitignore`.
- Do not add a `Podfile.lock`/`Pods/` removal as an unrelated cleanup.
