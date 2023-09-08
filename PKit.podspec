#
#  Be sure to run `pod spec lint PKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "PKit"
  spec.version      = "0.3.0"
  spec.summary      = "A short description of PKit."

  spec.homepage     = "https://github.com/zx1262111739/PKit"
  spec.license      = "MIT"
  spec.author             = { "Plumk" => "plumk97@outlook.com" }
  spec.source       = { :git => "https://github.com/zx1262111739/PKit.git", :tag => "#{spec.version}" }

  spec.ios.deployment_target = "11.0"
  
  
  spec.swift_version = "5.0"

  spec.default_subspec = 'Core', 'UI'
  
  spec.subspec 'Core' do |s|
    s.source_files = "Core", "Sources/Core/**/*.swift"
  end
  
  spec.subspec 'UI' do |s|
    s.source_files  = "Classes", "Sources/UI/**/*.swift"
  end
  
  spec.subspec 'Util' do |s|
    s.source_files  = "Classes", "Sources/Util/**/*.swift"
  end

  spec.subspec 'JSON' do |s|
    s.source_files = "JSON", "Sources/JSON/**/*.swift"
  end

  spec.subspec 'JSON_Rx' do |s|
    s.source_files = "JSON_Rx", "Sources/JSON/**/*.swift"
    s.dependency "RxRelay"
  end
  
  
end
