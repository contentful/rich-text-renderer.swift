#!/bin/bash
# Sets the library version in every file that carries it.
#   ContentfulRichTextRenderer.podspec  -> spec.version (also used as the release tag)
#   RichTextRenderer.xcodeproj          -> MARKETING_VERSION (the framework's CFBundleShortVersionString)
#
# Usage: ./Scripts/set-version.sh X.Y.Z

set -euo pipefail

cd "$(dirname "$0")/.."

VERSION="${1:-}"
if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "usage: $0 X.Y.Z" >&2
  exit 1
fi

sed -i '' -E "s/^([[:space:]]*spec\.version[[:space:]]*=[[:space:]]*)\"[^\"]*\"/\1\"$VERSION\"/" ContentfulRichTextRenderer.podspec
sed -i '' -E "s/MARKETING_VERSION = [^;]*;/MARKETING_VERSION = $VERSION;/" RichTextRenderer.xcodeproj/project.pbxproj

echo "Version set to $VERSION in ContentfulRichTextRenderer.podspec and RichTextRenderer.xcodeproj"
echo "Also update the version in the README install snippets (SPM, Carthage)."
