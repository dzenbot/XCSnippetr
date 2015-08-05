source 'https://github.com/CocoaPods/Specs.git'

workspace 'XCSnippetr-Builder.xcworkspace'
xcodeproj 'XCSnippetr-Builder.xcodeproj'

platform :osx

link_with 'XCSnippetr', 'XCSnippetrApp'

target 'XCSnippetr' do
  pod 'DTXcodeUtils'
  pod 'SSKeychain', '~> 1.2'
  pod 'ACEView', :git => 'https://github.com/faceleg/ACEView.git', :commit => '821cfd9' # this commit includes objective-c syntax detection
end