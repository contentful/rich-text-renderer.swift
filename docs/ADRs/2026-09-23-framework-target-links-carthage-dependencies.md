# Link the framework target against Carthage-built dependencies, not CocoaPods static libraries

- **Date:** 2026-09-23
- **Status:** Accepted
- **Supersedes in part:** [2026-08-25 — Commit the resolved CocoaPods `Pods/` directory](./2026-08-25-commit-cocoapods-pods-directory.md) (the part about how Carthage builds the framework)

## Context

The `RichTextRenderer` framework target in `RichTextRenderer.xcodeproj` got Contentful, AlamofireImage and Alamofire from the committed `Pods/` as **static libraries**. The `Podfile` has no `use_frameworks!`, and the target linked `libPods-RichTextRenderer.a` with the Pods `.xcconfig` files as its base configurations. So every `RichTextRenderer.framework` built from the project contained full copies of those three libraries. Checked 2026-09-23:

| Binary | Contentful symbols | Alamofire symbols | AlamofireImage symbols | Size (ios-arm64) |
|---|---|---|---|---|
| `RichTextRenderer.xcframework.zip` attached to release 0.4.9 | 1,591 | 2,535 | 353 | 4.1 MB |
| Carthage source build of `master` before this change | 1,592 | 2,557 | embedded | ~4 MB |

Carthage builds the dependencies from `Cartfile` itself, and the README tells users to add every XCFramework from `Carthage/Build`. Carthage apps therefore shipped **two copies** of Contentful, AlamofireImage and Alamofire: Carthage's, and the one inside RichTextRenderer. That's the classic "Class … is implemented in both" situation, with duplicate state such as two image caches, and it's fragile at runtime. SPM and CocoaPods users were not affected, because both build the library from `Package.swift` or the podspec, not from this target.

## Decision

The `RichTextRenderer` framework target no longer uses CocoaPods. It links, without embedding, the dynamic frameworks Carthage builds from `Cartfile`/`Cartfile.resolved`:

- `Carthage/Build/Contentful.xcframework`
- `Carthage/Build/AlamofireImage.xcframework`
- `Carthage/Build/Alamofire.xcframework`

The target's Pods base configurations, `libPods-RichTextRenderer.a` and the `[CP] Check Pods Manifest.lock` phase were removed, the `RichTextRenderer` target was removed from the `Podfile`, and `Cartfile.resolved` is now committed so the dependency versions are reproducible.

When Carthage builds this repository as a dependency, it links the checkout's `Carthage/Build` to the consumer's, so the framework resolves against the same Contentful, AlamofireImage and Alamofire that the consumer ships. After the change, the Carthage-built framework has 0 Alamofire and 0 AlamofireImage symbols. Its only Contentful symbols are RichTextRenderer's own conformances on Contentful node types, such as `extension BlockQuote: RenderableNodeProviding`. It links `@rpath/Contentful.framework`, `@rpath/AlamofireImage.framework` and `@rpath/Alamofire.framework`, and it is 610 KB.

`Scripts/release.sh carthage-check` enforces this on every release: it fails if the framework embeds any of the three libraries or doesn't link them dynamically.

No prebuilt XCFramework is attached to releases. Alamofire and AlamofireImage are not built with library evolution, so a prebuilt RichTextRenderer binary would only be ABI-safe with the exact Alamofire and AlamofireImage versions (and Swift compiler) it was built against. Without a binary, Carthage builds RichTextRenderer from source against the consumer's own resolved versions.

## Consequences

- To build the framework target in Xcode, developers first run `carthage bootstrap --use-xcframeworks --platform iOS`. `Carthage/` stays git-ignored.
- `Pods/` stays committed. The example apps still get their dependencies and the library (through the local podspec) from CocoaPods, and they build without running `pod install`. `Pods/` was regenerated with `pod install` as part of this change. That removed the unused `Pods-RichTextRenderer` aggregate target, and fixed the example-app builds, which had been broken because the stale `Pods/` compiled the library pod for iOS 8–11. At the same time the `Podfile` moved to `https://cdn.cocoapods.org/` and iOS 13.0.
- The earlier ADR's warning "deleting `Pods/` breaks the Carthage install path" no longer applies. Deleting it would now break only the example apps.
- SPM and CocoaPods users are unaffected.

## Alternatives considered

- **`use_frameworks!` in the `Podfile`.** This makes the Pods dynamic, but the framework would then be compiled against the Pods' dependency versions (`Podfile.lock`: Contentful 5.5.7, Alamofire 5.6.4) while running against Carthage's (5.5.15, 5.12.2). Those builds aren't library-evolution-safe, so that mismatch is unsafe.
- **Drop Carthage support** and point users to SPM. This was rejected for now because Carthage is still a documented install path.
