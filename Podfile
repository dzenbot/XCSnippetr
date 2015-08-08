source 'https://github.com/CocoaPods/Specs.git'

platform :osx, '10.9'
xcodeproj 'XCSnippetr-Builder.xcodeproj'

target :XCSnippetrPlugin do
    pod 'DTXcodeUtils'
    pod 'SSKeychain', '~> 1.2'
    pod 'ACEView', :git => 'https://github.com/faceleg/ACEView.git', :commit => '2437ca5'
end

target :XCSnippetrApp do
    pod 'SSKeychain', '~> 1.2'
    pod 'ACEView', :git => 'https://github.com/faceleg/ACEView.git', :commit => '2437ca5'
end

target :XCSnippetrTests do
    pod 'Specta', '0.5.0'
end
