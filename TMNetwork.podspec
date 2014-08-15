#
#  Be sure to run `pod spec lint TMNetwork.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "TMNetwork"
  s.version      = "0.0.3"
  s.summary      = "Simple networking that makes sense."

  s.homepage     = "https://github.com/tonymillion/TMNetwork"

  s.license      = "BSD"

  s.author             = { "Tony Million" => "tonymillion@gmail.com" }
  s.social_media_url   = "http://twitter.com/tonymillion"

  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/tonymillion/TMNetwork.git", :tag => "0.0.3" }

  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

  s.requires_arc = true

end
