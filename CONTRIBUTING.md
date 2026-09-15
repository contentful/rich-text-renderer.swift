# Contributing

Thanks for helping improve `ContentfulRichTextRenderer`. This document describes how
this repository actually works today, including the parts that are thinner than you
might expect.

## Before you start: what this repo does and does not give you

- **There is no test suite.** No test target exists in `Package.swift` and the shared
  scheme `RichTextRenderer.xcodeproj/xcshareddata/xcschemes/RichTextRenderer.xcscheme`
  declares no testable references. Changes are verified by building the library and
  exercising an example app by hand.
- **There is no dedicated build workflow.** The only committed workflow,
  `.github/workflows/codeql.yml`, runs solely when files under
  `.github/workflows/**` change. The compile signal on a PR comes from CodeQL
  **default setup**, enabled at the repo level for `actions`, `ruby`, and `swift`
  and therefore not visible anywhere in `.github/workflows/`. The `Analyze (swift)`
  job does build the library, but it is slow and it is a security-analysis job, not
  a build gate — build locally rather than waiting on it. Wiz scanners and a
  `Governance Controls` check also run from org configuration.
- **`Pods/` is committed.** That is intentional; see
  `docs/ADRs/2026-08-25-commit-cocoapods-pods-directory.md`. Running `pod install`
  will produce a large but legitimate diff.
- This is a maintenance-mode library. Development is low-volume — recent work is
  targeted bug fixes (hyperlink encoding, table layout, dark mode) rather than
  feature development. Keep changes small and focused.

## Setup

Requirements: Xcode with a Swift 5.2-or-later toolchain, an iOS 13+ simulator, and
Ruby with Bundler for CocoaPods.

```sh
git clone https://github.com/contentful/rich-text-renderer.swift.git
cd rich-text-renderer.swift
bundle install            # cocoapods, xcpretty, slather, jazzy, dotenv (see Gemfile)
open RichTextRenderer.xcworkspace
```

The workspace contains `RichTextRenderer.xcodeproj` (the library),
`Example-iOS`, `Example-iOS-SwiftUI`, and `Pods/Pods.xcodeproj`.

## Building and checking your change

```sh
# Library only
xcodebuild -project RichTextRenderer.xcodeproj -scheme RichTextRenderer \
  -sdk iphonesimulator -configuration Debug build

# Swift Package Manager dependency resolution
swift package resolve
```

`swift build` from the command line on macOS will not work: the target is iOS-only
and imports UIKit.

To validate behaviour, run one of the example apps. Both fetch from a real Contentful
space via `Example-iOS*/Example-iOS*/Contentful/ContentfulService.swift`, so you need
your own space credentials — there are none checked in, and you must not check any in.

If your change affects the public API surface as consumed via CocoaPods, also run:

```sh
bundle exec pod lib lint ContentfulRichTextRenderer.podspec
```

## Branches and commits

- The default branch is **`master`**, not `main`. Branch from it and target it.
- Recent branches follow `<type>/<short-description>`, e.g. `chore/swift-ui-example`,
  `fix/embed-views-layout`, `chore/dx-5-remove-tundra`. Older branches are less
  consistent; follow the recent pattern.
- Commit subjects use Conventional-Commit-style prefixes. In practice this repo has
  used almost only `chore:` (21 of the last 122 non-merge commits) and `fix:` (2);
  much of the older history has no prefix at all. Use the conventional prefix that
  actually describes your change and do not retro-fix old subjects.
- Where a change corresponds to a Jira issue, put the key in brackets at the end of
  the subject: `chore: remove team-tundra from owners [DX-5]`,
  `chore: set up Renovate for dependency updates [MEC-3447]`.
- There is **no** semantic-release or release automation wired to commit types, so a
  `feat:` prefix will not publish anything by itself. Version bumps are manual (see
  Releasing).

## Pull requests

1. Open the PR against `master`.
2. Describe what you changed and, since there are no tests, **how you verified it** —
   which example app, which simulator, which node types you exercised.
3. `.github/CODEOWNERS` assigns every path to `@contentful/group-applied-ai-solutions`,
   so that team's review is required.
4. Dependency updates arrive automatically via Renovate (`renovate.json` extends
   `local>contentful/renovate-config`). Prefer letting Renovate raise dependency
   bumps rather than hand-editing versions.

## Where code goes

Match the existing layout under `Sources/RichTextRenderer/` — see
[ARCHITECTURE.md](./ARCHITECTURE.md) for what each directory is responsible for.

- A new node type needs: a case in `Models/RenderableNode.swift`, a conformance in
  `Extensions/Node+RenderableNodeProviding.swift`, a property on
  `Renderer/NodeRenderersProviding.swift` plus its `switch` case, a default in
  `Renderer/Default/DefaultRenderersProvider.swift`, and a renderer under
  `NodeRenderers/<NodeType>/`. Adding a property to `NodeRenderersProviding` is a
  breaking change for anyone with a custom conformance — call that out in the PR.
- Configuration knobs go in `Configuration/` with a `+Default.swift` companion, and
  are exposed through `RendererConfiguration` / `DefaultRendererConfiguration`.
- Extensions on Foundation/UIKit types are named `Type+Behaviour.swift`.

## Style

There is no SwiftLint or swift-format configuration in this repo, so style is upheld
by convention:

- 4-space indentation; multi-line call sites break one argument per line.
- Most source files open with a `// RichTextRenderer` header comment — keep it on new
  files.
- Document public symbols with `///` (or `/** */` for multi-line) doc comments. The
  existing public API is documented and new public API should be too.
- Do not reformat code you are not otherwise changing.

## Cross-channel changes

The library ships through three package managers, each with its own manifest:
`Package.swift` (SPM), `ContentfulRichTextRenderer.podspec` + `Podfile` (CocoaPods),
and `Cartfile` (Carthage). A dependency or platform-floor change usually needs to be
made in more than one of them. These manifests are currently not fully aligned — the
`Podfile` still declares `platform :ios, '11.0'` while the podspec and `Package.swift`
declare iOS 13, and the podspec's `homepage`/`source` still reference the old
`contentful-labs` organisation. If you correct one of these, do it as its own commit
and say so in the PR body.

## Releasing

Releases are performed by the maintaining team and are manual:

1. Bump `spec.version` in `ContentfulRichTextRenderer.podspec`.
2. Merge to `master`.
3. Tag the merge commit with the bare version number — tags in this repo have no `v`
   prefix (`0.4.1` … `0.4.10`).
4. Publish the pod to CocoaPods trunk.

There is no `CHANGELOG.md`; the tag history and PR titles are the record.

## Reporting issues and asking questions

- Bugs and feature requests: open a GitHub issue on this repository.
- Usage questions: the [Contentful community forum](https://support.contentful.com/)
  or the [community Slack](https://www.contentful.com/slack/), as linked from the
  README.

## Code of Conduct

Participation is governed by the
[Contentful community Code of Conduct](https://github.com/contentful-developer-relations/community-code-of-conduct).

## License

Contributions are accepted under the [MIT license](LICENSE) that covers this
repository.
