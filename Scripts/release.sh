#!/bin/bash
# Release rich-text-renderer.swift. CircleCI runs the same steps as a manual release. See RELEASING.md.
#
# Usage: ./Scripts/release.sh <step>
#
#   validate        podspec and Xcode project versions agree, version is new and greater than the
#                   last tag, commit is on origin/master, no branch named like the version,
#                   working tree clean
#   carthage-check  build the library the way Carthage users do (carthage bootstrap + build from source)
#                   and fail if the framework embeds Contentful, Alamofire or AlamofireImage
#   tag             tag RELEASE_COMMIT (default: HEAD) and push only that tag
#   github-release  create the GitHub release with generated notes (no binary, see RELEASING.md)
#   all             validate, carthage-check, tag, github-release
#
# Environment:
#   DRY_RUN=1        print the commands that would change anything on GitHub instead of running them
#   RELEASE_COMMIT   commit to tag (CI passes $CIRCLE_SHA1); defaults to HEAD
#   GITHUB_TOKEN     used for pushes and the GitHub API when set (CI); otherwise your git/gh auth is used
#   GIT_REMOTE       remote to fetch from and push to (default: origin)
#
# CocoaPods: new versions are no longer pushed to trunk (read-only from 2026-12-02). Existing
# versions stay installable.

set -euo pipefail

cd "$(dirname "$0")/.."

ROOT="$(pwd)"
REPO_SLUG="contentful/rich-text-renderer.swift"
GIT_REMOTE="${GIT_REMOTE:-origin}"
DRY_RUN="${DRY_RUN:-0}"

VERSION="$(sed -n -E 's/^[[:space:]]*spec\.version[[:space:]]*=[[:space:]]*"([^"]*)".*/\1/p' ContentfulRichTextRenderer.podspec)"

if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  export GH_TOKEN="${GH_TOKEN:-$GITHUB_TOKEN}"
fi

log()  { printf '\n==> %s\n' "$*"; }
fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

# Runs a command that changes remote state, or prints it when DRY_RUN=1.
publish() {
  if [[ "$DRY_RUN" == "1" ]]; then
    printf '[dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

# git with GitHub auth from GITHUB_TOKEN when it is set (CI). Locally it falls back to your own credentials.
git_auth() {
  if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    local basic
    basic="$(printf 'x-access-token:%s' "$GITHUB_TOKEN" | base64 | tr -d '\n')"
    git -c "http.https://github.com/.extraheader=AUTHORIZATION: basic $basic" "$@"
  else
    git "$@"
  fi
}

# Remote to push to: an HTTPS URL when a token is available (CI checkout keys are read-only), else GIT_REMOTE.
push_target() {
  if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    echo "https://github.com/$REPO_SLUG.git"
  else
    echo "$GIT_REMOTE"
  fi
}

remote_tag_sha() {
  git_auth ls-remote "$(push_target)" "refs/tags/$VERSION^{}" "refs/tags/$VERSION" | awk 'NR==1{print $1}'
}

step_validate() {
  log "Validating release $VERSION"

  [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "ContentfulRichTextRenderer.podspec has an invalid version '$VERSION'"

  local marketing
  marketing="$(sed -n -E 's/.*MARKETING_VERSION = ([^;]*);.*/\1/p' RichTextRenderer.xcodeproj/project.pbxproj | sort -u)"
  [[ "$marketing" == "$VERSION" ]] \
    || fail "RichTextRenderer.xcodeproj MARKETING_VERSION is '$marketing' but the podspec has '$VERSION'. Run ./Scripts/set-version.sh $VERSION"

  [[ -z "$(git status --porcelain --untracked-files=no)" ]] \
    || fail "Working tree has uncommitted changes to tracked files"

  git fetch --quiet --tags --force "$GIT_REMOTE"

  if [[ -n "$(remote_tag_sha)" ]]; then
    fail "Tag $VERSION already exists on $GIT_REMOTE. Bump the version with ./Scripts/set-version.sh"
  fi

  local latest
  latest="$(git tag -l '[0-9]*.[0-9]*.[0-9]*' | sort -V | tail -1)"
  if [[ -n "$latest" ]]; then
    [[ "$(printf '%s\n%s\n' "$latest" "$VERSION" | sort -V | tail -1)" == "$VERSION" ]] \
      || fail "$VERSION is not greater than the latest tag $latest"
  fi

  if git ls-remote --exit-code --heads "$GIT_REMOTE" "$VERSION" >/dev/null 2>&1; then
    fail "A branch named '$VERSION' exists on $GIT_REMOTE. Rename or delete it, because it makes the tag ambiguous"
  fi

  local commit
  commit="$(git rev-parse "${RELEASE_COMMIT:-HEAD}^{commit}")"
  if ! git merge-base --is-ancestor "$commit" "$GIT_REMOTE/master" 2>/dev/null; then
    git fetch --quiet "$GIT_REMOTE" master
    git merge-base --is-ancestor "$commit" "$GIT_REMOTE/master" \
      || fail "Commit $commit is not on $GIT_REMOTE/master. Releases are made from master only"
  fi

  echo "OK: $VERSION (previous: ${latest:-none}) from $commit"
}

step_carthage_check() {
  log "Building RichTextRenderer with Carthage (as Carthage users do)"
  command -v carthage >/dev/null 2>&1 || fail "'carthage' is required. Install it with: brew install carthage"

  local derived="$ROOT/build/DerivedData-carthage"
  # --no-skip-current builds every shared scheme it finds in the repo, including the Alamofire and
  # Contentful projects in package checkouts left by local SPM builds (-derivedDataPath build/...).
  rm -rf "$ROOT"/build/*/SourcePackages
  carthage bootstrap --use-xcframeworks --platform iOS --derived-data "$derived"
  rm -rf Carthage/Build/RichTextRenderer.xcframework
  carthage build --no-skip-current --use-xcframeworks --platform iOS --derived-data "$derived"

  local binary="Carthage/Build/RichTextRenderer.xcframework/ios-arm64/RichTextRenderer.framework/RichTextRenderer"
  [[ -f "$binary" ]] || fail "Carthage did not produce $binary"

  # The framework must link its dependencies dynamically, not contain copies of them.
  # (RichTextRenderer's own extensions on Contentful types are fine; they are not type metadata.)
  local symbols dependency
  symbols="$(nm -gU "$binary")"
  for dependency in '$s9Alamofire' '$s14AlamofireImage' '$s10Contentful6ClientC'; do
    if grep -qF "_$dependency" <<<"$symbols"; then
      fail "RichTextRenderer.framework embeds ${dependency} symbols. The framework target must link the Carthage-built frameworks, not static libraries"
    fi
  done
  for dependency in Contentful AlamofireImage Alamofire; do
    otool -L "$binary" | grep -q "@rpath/$dependency.framework/" \
      || fail "RichTextRenderer.framework does not link $dependency.framework dynamically"
  done
  echo "OK: RichTextRenderer.framework links Contentful, AlamofireImage and Alamofire dynamically ($(du -h "$binary" | cut -f1))"
}

step_tag() {
  local commit existing
  commit="$(git rev-parse "${RELEASE_COMMIT:-HEAD}^{commit}")"
  log "Tagging $commit as $VERSION"

  existing="$(remote_tag_sha)"
  if [[ -n "$existing" ]]; then
    [[ "$existing" == "$commit" ]] || fail "Tag $VERSION already exists on a different commit ($existing)"
    echo "Tag $VERSION already points at $commit, nothing to do"
    return
  fi

  if git rev-parse -q --verify "refs/tags/$VERSION" >/dev/null; then
    [[ "$(git rev-parse "refs/tags/$VERSION^{commit}")" == "$commit" ]] \
      || fail "A local tag $VERSION exists on a different commit. Delete it with: git tag -d $VERSION"
  elif [[ "$DRY_RUN" == "1" ]]; then
    printf '[dry-run] git tag %s %s\n' "$VERSION" "$commit"
  else
    git tag "$VERSION" "$commit"
  fi

  # Push only this tag, never --tags.
  publish git_auth push "$(push_target)" "refs/tags/$VERSION"
}

step_github_release() {
  log "Publishing GitHub release $VERSION"
  command -v gh >/dev/null 2>&1 || fail "'gh' is required. Install it with: brew install gh"

  if gh release view "$VERSION" --repo "$REPO_SLUG" >/dev/null 2>&1; then
    echo "Release $VERSION already exists, nothing to do"
    return
  fi

  publish gh release create "$VERSION" \
    --repo "$REPO_SLUG" \
    --title "$VERSION" \
    --generate-notes \
    --latest \
    --verify-tag
}

case "${1:-}" in
  validate)       step_validate ;;
  carthage-check) step_carthage_check ;;
  tag)            step_tag ;;
  github-release) step_github_release ;;
  all)
    step_validate
    step_carthage_check
    step_tag
    step_github_release
    if [[ "$DRY_RUN" == "1" ]]; then
      log "Dry run of $VERSION finished. Nothing was pushed"
    else
      log "rich-text-renderer.swift $VERSION released"
    fi
    ;;
  *)
    sed -n '2,21p' "$0" | sed 's/^# \{0,1\}//'
    exit 1
    ;;
esac
