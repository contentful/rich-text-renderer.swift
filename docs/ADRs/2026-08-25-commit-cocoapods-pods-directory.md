# Commit the resolved CocoaPods `Pods/` directory to the repository

- **Date:** 2026-08-25
- **Status:** Accepted (in effect since 2023-05-05)

> This record was written on 2026-08-25 from the commit history. It documents an
> existing decision rather than a new one; the rationale below is reconstructed from
> the commit message, the diff, and the surrounding build configuration, not from a
> contemporaneous design discussion.

## Context

`ContentfulRichTextRenderer` is distributed through three package managers at once,
each with its own manifest in the repository root:

- Swift Package Manager — `Package.swift`
- CocoaPods — `ContentfulRichTextRenderer.podspec`, `Podfile`
- Carthage — `Cartfile`

The library itself depends on `contentful.swift` and `AlamofireImage` (which pulls in
`Alamofire`). The Xcode project `RichTextRenderer.xcodeproj` is built inside
`RichTextRenderer.xcworkspace`, which references `Pods/Pods.xcodeproj` as a peer —
so the Xcode build of the framework target resolves its dependencies through
CocoaPods, and the generated `Pods` project and `.xcconfig` files are part of that
build's inputs.

Carthage builds a dependency by checking out its repository at a tag and invoking
`xcodebuild` on the schemes it finds there. It does not run `pod install` first.
Before May 2023, `.gitignore` excluded `Pods/`, `build`, `.build`, `Packages`,
`*.xcscmblueprint`, and `/Podfile.lock`, which meant a fresh Carthage checkout of
this repository had no `Pods` project and no generated `.xcconfig` files — the
`RichTextRenderer` scheme could not build.

## Decision

Stop ignoring CocoaPods output and commit the resolved `Pods/` directory (and
`Podfile.lock`) so that a bare checkout of the repository is buildable by `xcodebuild`
without a CocoaPods install step.

The change was made in commit
[`0a53cfa694315bbdcde66558fcd9f63874a373a5`](https://github.com/contentful/rich-text-renderer.swift/commit/0a53cfa694315bbdcde66558fcd9f63874a373a5)
— "COCOA-162: Add pods folder to build for Carthage build to work", 2023-05-05 —
which removed those five entries from `.gitignore` and added 139 files / ~28,500
lines, including the full sources of Alamofire, AlamofireImage, and Contentful under
`Pods/`.

`Pods/` remains committed on `master` today: 133 files, roughly 1.6 MB.

## Consequences

**What this buys us**

- Carthage consumers can build the library from a tag with no extra tooling. The
  README's documented Carthage flow (`carthage update --platform iOS
  --use-xcframeworks`) works as written.
- Anyone cloning the repository can open `RichTextRenderer.xcworkspace` and build
  immediately, without a working Ruby/CocoaPods setup.

**What it costs us**

- Third-party source is vendored in this repository, so unrelated changes now carry
  generated-file churn. `44316e0` ("chore: add SwiftUI example project", 2025-09-03)
  touches 14 files under `Pods/` for 1,185 insertions and 656 deletions, and
  `cfb16e9` ("Expose apis to set text view background color…", 2023-07-19) rewrites
  213 lines of `Pods/Pods.xcodeproj/project.pbxproj` for no functional reason. That
  noise sits in the same diff as the reviewable change.
- The vendored copies can drift from the versions the other two channels resolve.
  `Package.resolved` currently pins Contentful 5.5.14 / AlamofireImage 4.3.0 /
  Alamofire 5.10.2, while `Podfile.lock` records its own checksums for the committed
  `Pods/` tree. Nothing in the repository enforces that these agree, and there is no
  CI that builds the library to catch a mismatch — the only workflow,
  `.github/workflows/codeql.yml`, scans `.github/workflows/**` only.
- Renovate (`renovate.json`) can update the manifests, but a manifest-only update
  leaves the committed `Pods/` tree stale until someone runs `pod install` and commits
  the result.

**Implications for anyone changing this repo**

- Do not re-add `Pods/` to `.gitignore` and do not delete the directory as cleanup —
  doing so breaks the Carthage install path.
- After changing a CocoaPods dependency, run `pod install` and commit the resulting
  `Pods/` changes in the same PR, and mention the vendored churn in the PR body.

## Alternatives that were available

Neither of these appears in the history; they are listed for anyone revisiting the
decision.

- Add a Carthage pre-build hook or a checked-in build script that runs `pod install`
  before `xcodebuild`. Carthage has no supported hook for this, which is likely why it
  was not chosen.
- Drop Carthage support and rely on SPM and CocoaPods only. `Cartfile` and the
  README's Carthage section are both still present, so Carthage support is still
  considered part of the product.
