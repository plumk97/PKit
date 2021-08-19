#
#  Be sure to run `pod spec lint PLKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "PLKKit"
  spec.version      = "0.0.2"
  spec.summary      = "A short description of PKKit."

  spec.homepage     = "https://github.com/zx1262111739/PLKKit"
  spec.license      = "MIT"
  spec.author             = { "Plumk" => "plumk97@outlook.com" }
  spec.source       = { :git => "https://github.com/zx1262111739/PLKKit.git", :tag => "#{spec.version}" }

  spec.platform     = :ios, "10.0"
  spec.ios.deployment_target = "10.0"
  spec.swift_version = "5.0"

  spec.source_files  = "Classes", "Classes/**/*.swift"
end
