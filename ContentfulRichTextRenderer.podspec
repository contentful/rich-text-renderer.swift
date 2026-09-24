#!/usr/bin/ruby

# CocoaPods trunk becomes read-only on 2026-12-02 and this library is frozen there at 0.4.10.
# This podspec is kept for existing users and the example apps, and new versions are not pushed (see RELEASING.md).

Pod::Spec.new do |spec|
  spec.name             = "ContentfulRichTextRenderer"
  spec.version          = "0.4.10"
  spec.summary          = "Swift library for rendering Contentful RichTextDocument."
  spec.homepage         = "https://github.com/contentful/rich-text-renderer.swift"
  spec.social_media_url = 'https://twitter.com/contentful'
  spec.authors          = 'Contentful'

  spec.license = { :type => "MIT", :file => "LICENSE" }

  spec.source       = { :git => "https://github.com/contentful/rich-text-renderer.swift.git", :tag => spec.version.to_s }

  spec.requires_arc = true
  
  spec.swift_version = "5.2"
  spec.ios.deployment_target = "13.0"

  spec.source_files = "Sources/RichTextRenderer/**/*.swift"

  spec.dependency 'AlamofireImage', '~> 4'
  spec.dependency 'Contentful', '~> 5'
end

