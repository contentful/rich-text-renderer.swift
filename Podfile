source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'

workspace 'RichTextRenderer.xcworkspace'

target 'RichTextRenderer' do
    pod 'AlamofireImage'
    pod 'Contentful', '~> 5'
end

target 'Example-iOS' do
  project 'Example-iOS/Example-iOS.xcodeproj'
  pod 'Contentful', '~> 5'
  pod 'ContentfulRichTextRenderer', :path => 'ContentfulRichTextRenderer.podspec'
end
