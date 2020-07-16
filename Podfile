platform :ios, '11.0'

workspace 'RichTextRenderer.xcworkspace'

target 'RichTextRenderer' do
    pod 'AlamofireImage'
    pod 'Contentful'
end

target 'Example-iOS' do
  xcodeproj 'Example-iOS/Example-iOS.xcodeproj'
  pod 'Contentful'
  pod 'ContentfulRichTextRenderer', :path => 'ContentfulRichTextRenderer.podspec'
end
