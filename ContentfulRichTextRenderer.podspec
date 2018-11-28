#!/usr/bin/ruby

Pod::Spec.new do |spec|
  spec.name             = "ContentfulRichTextRenderer"
  spec.version          = "0.0.1"
  spec.summary          = "Swift library for rendering Contentful RichText."
  spec.homepage         = "https://github.com/contentful-labs/rich-text-renderer.swift/"
  spec.social_media_url = 'https://twitter.com/contentful'

  spec.license = {
      :type => 'MIT',
      :file => 'LICENSE'
  }

  spec.authors      = { "JP Wright" => "jp@contentful.com" }
  spec.source       = { :git => "https://github.com/contentful-labs/rich-text-renderer.swift.git",
                        :tag => spec.version.to_s }
  spec.requires_arc = true
  
  spec.swift_version = '4.2'
  spec.ios.deployment_target = '9.3'

  spec.source_files = 'Sources/RichTextRenderer/*.swift'
  spec.ios.source_files = 'Sources/RichTextRenderer/UIKit/*.swift'

  spec.dependency 'AlamofireImage', '~> 3.4'
  spec.dependency 'Contentful', '~> 4'
end

